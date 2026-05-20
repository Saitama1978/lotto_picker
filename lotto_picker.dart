import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Siguraduhing naka-initialize ang Firebase bago mag-run ang app
  await Firebase.initializeApp();
  runApp(const LottoAsintadoApp());
}

class LottoAsintadoApp extends StatelessWidget {
  const LottoAsintadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PH Lotto Asintado Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _strategyTabController;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("pcso_data");

  final List<String> strategies = ['Hot Frequency', 'Odd/Even Balance', 'High/Low Range'];
  final List<String> lottoGames = ['6/58', '6/55', '6/49', '6/45', '6/42', '2D', '3D', '4D', '6D'];
  
  String selectedGameFreq = '3D'; 
  String selectedGameOddEven = '3D';
  String selectedGameHiLo = '3D';

  List<int> generatedNumbers = [];

  // Ginawa nating dynamic ang Lalagyan ng Realtime Data
  Map<String, dynamic> liveResultsData = {};

  final Map<String, List<int>> hotNumbersPool = {
    '6/58': [3, 9, 12, 17, 24, 31, 38, 41, 44, 55, 56],
    '6/55': [5, 10, 19, 22, 33, 41, 48, 52, 54],
    '6/49': [3, 8, 17, 29, 31, 42, 45],
    '6/45': [7, 11, 13, 21, 35, 44],
    '6/42': [5, 9, 12, 18, 24, 38],
    '2D': [11, 28, 5, 14, 22, 31],
    '3D': [5, 9, 2, 7, 0],
    '4D': [8, 3, 0, 6, 1, 9],
    '6D': [4, 1, 9, 0, 5, 7, 2],
  };

  @override
  void initState() {
    super.initState();
    _strategyTabController = TabController(length: strategies.length, vsync: this);
    _strategyTabController.addListener(() {
      if (_strategyTabController.indexIsChanging) {
        setState(() {
          generatedNumbers.clear();
        });
      }
    });

    // Makinig sa pagbabago ng Firebase Database nang live!
    _dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          // I-convert ang data mula Firebase para pumasok sa app map structure
          liveResultsData = data.map((key, value) => MapEntry(key.toString(), value));
        });
      }
    });
  }

  @override
  void dispose() {
    _strategyTabController.dispose();
    super.dispose();
  }

  void generateNumbersByStrategy(String strategy, String game) {
    Random random = Random();
    List<int> resultList = [];

    if (game.contains('D')) {
      int digitsToGenerate = int.parse(game.replaceAll('D', ''));
      List<int> pool = hotNumbersPool[game] ?? [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
      
      for (int i = 0; i < digitsToGenerate; i++) {
        if (game == '2D') {
          if (strategy == 'Hot Frequency') {
            resultList.add(pool[random.nextInt(pool.length)]);
          } else {
            resultList.add(random.nextInt(31) + 1);
          }
        } else {
          if (strategy == 'Hot Frequency') {
            resultList.add(pool[random.nextInt(pool.length)]);
          } else {
            resultList.add(random.nextInt(10));
          }
        }
      }
    } else {
      int maxNum = int.parse(game.split('/').last);
      List<int> pool = hotNumbersPool[game] ?? [];
      
      List<int> validPool = List.from(pool);
      while (validPool.length < 15) {
        int rNum = random.nextInt(maxNum) + 1;
        if (!validPool.contains(rNum)) validPool.add(rNum);
      }

      while (true) {
        resultList.clear();
        
        if (strategy == 'Hot Frequency') {
          while (resultList.length < 6) {
            int picked = validPool[random.nextInt(validPool.length)];
            if (!resultList.contains(picked)) resultList.add(picked);
          }
          break;
        } else {
          while (resultList.length < 6) {
            int picked = random.nextInt(maxNum) + 1;
            if (!resultList.contains(picked)) resultList.add(picked);
          }
          
          int oddCount = resultList.where((num) => num % 2 != 0).length;
          int midPoint = (maxNum / 2).round();
          int lowCount = resultList.where((num) => num <= midPoint).length;

          if (strategy == 'Odd/Even Balance') {
            if (oddCount >= 2 && oddCount <= 4) break;
          }
          if (strategy == 'High/Low Range') {
            if (lowCount >= 2 && lowCount <= 4) break;
          }
        }
      }
      resultList.sort();
    }

    setState(() {
      generatedNumbers = resultList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('🎯 LOTTO ASINTADO STRATEGY PRO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Developer: Renante Fullo', style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _strategyTabController,
          isScrollable: true, 
          tabAlignment: TabAlignment.center, 
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5), 
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: strategies.map((strat) => Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), 
              child: Text(strat.toUpperCase()),
            ),
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _strategyTabController,
        children: [
          _buildStrategyTabContent('Hot Frequency', selectedGameFreq, (val) => setState(() => selectedGameFreq = val!)),
          _buildStrategyTabContent('Odd/Even Balance', selectedGameOddEven, (val) => setState(() => selectedGameOddEven = val!)),
          _buildStrategyTabContent('High/Low Range', selectedGameHiLo, (val) => setState(() => selectedGameHiLo = val!)),
        ],
      ),
    );
  }

  Widget _buildStrategyTabContent(String strategyName, String currentSelectedGame, ValueChanged<String?> onGameChanged) {
    // Dito kinukuha ang live data mula Firebase. Kung wala pa, may loading indicator.
    var gameData = liveResultsData[currentSelectedGame];
    
    String gameName = gameData != null && gameData['name'] != null ? gameData['name'] : '$currentSelectedGame Lotto';
    String drawDate = gameData != null && gameData['date'] != null ? gameData['date'] : 'Loading...';
    String drawResult = gameData != null && gameData['result'] != null ? gameData['result'] : '-- -- --';
    String jackpotPrize = gameData != null && gameData['jackpot'] != null ? gameData['jackpot'] : 'Updating...';

    // Para sa History section
    List<dynamic> historyList = [];
    if (gameData != null && gameData['history'] != null) {
      if (gameData['history'] is List) {
        historyList = gameData['history'];
      } else if (gameData['history'] is Map) {
        historyList = (gameData['history'] as Map).values.toList();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text('📡 LIVE MONITOR DISPLAY', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('$gameName | $drawDate', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  Text(drawResult, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.yellow, letterSpacing: 1.5)),
                  Text('Jackpot: $jackpotPrize', style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          
          Text('📅 DAILY CALENDAR HISTORY ($currentSelectedGame)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(height: 4),
          SizedBox(
            height: 65,
            child: historyList.isEmpty
                ? Container(
                    decoration: BoxDecoration(color: Colors.grey[950], borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: const Text('Updating history logs...', style: TextStyle(fontSize: 11, color: Colors.white24, fontStyle: FontStyle.italic)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: historyList.length,
                    borderColor: Colors.white10,
                    itemBuilder: (context, index) {
                      var hist = historyList[index];
                      String histDate = hist != null && hist['date'] != null ? hist['date'] : 'N/A';
                      String histResult = hist != null && hist['result'] != null ? hist['result'] : '-- --';
                      return Container(
                        width: 195,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[950], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(histDate, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                            Text(histResult, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          
          DropdownButtonFormField<String>(
            value: currentSelectedGame,
            decoration: InputDecoration(
              labelText: 'Target Draw Selector',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[950],
            ),
            items: lottoGames.map((String game) {
              return DropdownMenuItem<String>(
                value: game,
                child: Text(game.contains('D') ? 'Digit Game: $game' : 'Lotto Game: $game'),
              );
            }).toList(),
            onChanged: (value) {
              onGameChanged(value);
              setState(() {
                generatedNumbers.clear(); 
              });
            },
          ),
          
          Expanded(
            child: Center(
              child: generatedNumbers.isEmpty
                  ? Text('Click Generate using $strategyName settings', style: const TextStyle(fontSize: 12, color: Colors.white38))
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: generatedNumbers.asMap().entries.map((entry) {
                        return _buildLottoBall(entry.value, isDigitGame: currentSelectedGame.contains('D'), position: entry.key + 1);
                      }).toList(),
                    ),
            ),
          ),
          
          ElevatedButton(
            onPressed: () => generateNumbersByStrategy(strategyName, currentSelectedGame),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'GENERATE VIA $strategyName', 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLottoBall(int number, {required bool isDigitGame, required int position}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDigitGame 
                ? [Colors.cyanAccent, Colors.blue, const Color(0xFF0D47A1)] 
                : [Colors.yellowAccent, Colors.amber, Colors.orange], 
              center: const Alignment(-0.3, -0.3),
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black54, offset: Offset(1, 3), blurRadius: 3),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            isDigitGame ? number.toString() : number.toString().padLeft(2, '0'),
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (isDigitGame) ...[
          const SizedBox(height: 2),
          Text('Digit $position', style: const TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }
}