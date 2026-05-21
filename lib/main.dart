import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q', // Palitan mo ng totoong Web API Key kung mayroon ka na, kung wala ok lang muna ito
        projectId: 'lotto-asintado',
        appId: '1:458447298380:android:308fd26da180954e40b9e9',
        messagingSenderId: '458447298380',
        storageBucket: 'lotto-asintado.appspot.com',
      ),
    );
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("⚠️ Running in offline-ready mode: $e");
  }
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
  
  final List<String> strategies = ['Hot Frequency', 'Odd/Even Balance', 'High/Low Range'];
  
  // Ginamit na natin ang Dash (-) dito boss para tugma sa Firebase!
  final List<String> lottoGames = ['6-58', '6-55', '6-49', '6-45', '6-42', '2D', '3D', '4D', '6D'];
  
  String selectedGameFreq = '3D'; 
  String selectedGameOddEven = '3D';
  String selectedGameHiLo = '3D';

  List<int> generatedNumbers = [];

  final Map<String, Map<String, String>> liveResultsData = {
    '3D': {'name': '3D Swertres', 'date': 'May 21, 2026', 'result': '1-2-4', 'jackpot': 'P4,500.00'},
    '2D': {'name': '2D EZ2 Lotto', 'date': 'May 21, 2026', 'result': '00-00', 'jackpot': 'P4,000.00'},
    '6-55': {'name': 'Grand Lotto 6/55', 'date': 'May 20, 2026', 'result': '00-00-00-00-00-00', 'jackpot': 'P29,700,000.00'},
    '6-58': {'name': 'Ultra Lotto 6/58', 'date': 'May 19, 2026', 'result': '00-00-00-00-00-00', 'jackpot': 'P49,500,000.00'},
    '6-49': {'name': 'Super Lotto 6/49', 'date': 'May 20, 2026', 'result': '00-00-00-00-00-00', 'jackpot': 'P16,000,000.00'},
    '6-45': {'name': 'Mega Lotto 6/45', 'date': 'May 18, 2026', 'result': '00-00-00-00-00-00', 'jackpot': 'P8,900,000.00'},
    '6-42': {'name': 'Lotto 6/42', 'date': 'May 19, 2026', 'result': '00-00-00-00-00-00', 'jackpot': 'P6,000,000.00'},
    '4D': {'name': '4D Lotto', 'date': 'May 20, 2026', 'result': '0-0-0-0', 'jackpot': 'P10,000.00'},
    '6D': {'name': '6D Lotto', 'date': 'May 19, 2026', 'result': '0-0-0-0-0-0', 'jackpot': 'P150,000.00'},
  };

  final Map<String, List<Map<String, String>>> historyLogsData = {
    '3D': [
      {'date': 'May 20, 2026', 'time': '2 PM', 'result': '9-5-2'},
      {'date': 'May 20, 2026', 'time': '5 PM', 'result': '4-7-1'},
      {'date': 'May 20, 2026', 'time': '9 PM', 'result': '3-0-8'},
    ],
  };

  final Map<String, List<int>> hotNumbersPool = {
    '6-58': [3, 9, 12, 17, 24, 31, 38, 41, 44, 55, 56],
    '6-55': [5, 10, 19, 22, 33, 41, 48, 52, 54],
    '6-49': [3, 8, 17, 29, 31, 42, 45],
    '6-45': [7, 11, 13, 21, 35, 44],
    '6-42': [5, 9, 12, 18, 24, 38],
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
  }

  @override
  void dispose() {
    _strategyTabController.dispose();
    super.dispose();
  }

  String _getDefaultPlaceholderResult(String game) {
    if (game == '2D') return '00-00';
    if (game == '3D') return '0-0-0';
    if (game == '4D') return '0-0-0-0';
    if (game == '6D') return '0-0-0-0-0-0';
    return '00-00-00-00-00-00';
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
      int maxNum = int.parse(game.split('-').last); // Binago mula slash papuntang dash
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lotto_games').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final gameKey = doc.id; 

              // Palitan ang pagpapakita ng pangalan mula dash papuntang slash para maganda pa rin tingnan sa app
              String displayName = gameKey.contains('-') ? 'Lotto ${gameKey.replaceAll('-', '/')}' : gameKey;

              liveResultsData[gameKey] = {
                'name': data['name']?.toString() ?? displayName,
                'date': data['date']?.toString() ?? 'No Data',
                'result': data['result']?.toString() ?? _getDefaultPlaceholderResult(gameKey),
                'jackpot': data['jackpot']?.toString() ?? 'N/A',
              };
            }
          }

          return TabBarView(
            controller: _strategyTabController,
            children: [
              _buildStrategyTabContent('Hot Frequency', selectedGameFreq, (val) => setState(() => selectedGameFreq = val!)),
              _buildStrategyTabContent('Odd/Even Balance', selectedGameOddEven, (val) => setState(() => selectedGameOddEven = val!)),
              _buildStrategyTabContent('High/Low Range', selectedGameHiLo, (val) => setState(() => selectedGameHiLo = val!)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStrategyTabContent(String strategyName, String currentSelectedGame, ValueChanged<String?> onGameChanged) {
    var liveData = liveResultsData[currentSelectedGame] ?? {
      'name': currentSelectedGame.contains('-') ? 'Lotto ${currentSelectedGame.replaceAll('-', '/')}' : '$currentSelectedGame Game',
      'date': 'Offline Ready',
      'result': _getDefaultPlaceholderResult(currentSelectedGame),
      'jackpot': '...'
    };
    var historyList = historyLogsData[currentSelectedGame] ?? [];

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
                  const Text('📡 CLOUD MONITOR ACTIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('${liveData['name']} | ${liveData['date']}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  Text(liveData['result']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.yellow, letterSpacing: 1.5)),
                  Text('Jackpot: ${liveData['jackpot']}', style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          
          Text('📅 PREVIOUS PCSO HISTORY ($currentSelectedGame)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(height: 4),
          SizedBox(
            height: 80, 
            child: historyList.isEmpty
                ? Container(
                    decoration: BoxDecoration(color: Colors.grey[950], borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: const Text('No historical logs available.', style: TextStyle(fontSize: 11, color: Colors.white24, fontStyle: FontStyle.italic)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      var hist = historyList[index];
                      String displayDate = hist['date']!.replaceAll(', 2026', '');
                      
                      String drawTime = hist['time'] != 'Draw' 
                          ? hist['time']! 
                          : (currentSelectedGame == '3D' 
                              ? (index % 3 == 0 ? '2 PM' : (index % 3 == 1 ? '5 PM' : '9 PM'))
                              : 'Draw');
                      
                      return Container(
                        width: (MediaQuery.of(context).size.width - 40) / 3,
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[950], 
                          borderRadius: BorderRadius.circular(8), 
                          border: Border.all(color: Colors.white10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              displayDate, 
                              style: const TextStyle(color: Colors.white60, fontSize: 9),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                drawTime, 
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hist['result']!, 
                              style: const TextStyle(color: Colors.yellowAccent, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
                              textAlign: TextAlign.center,
                            ),
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
              String labelName = game.contains('-') ? game.replaceAll('-', '/') : game;
              return DropdownMenuItem<String>(
                value: game,
                child: Text(game.contains('D') ? 'Digit Game: $labelName' : 'Lotto Game: $labelName'),
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
