import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Awtomatikong babasahin ang google-services.json mo
    await Firebase.initializeApp();
  } catch (e) {
    print("⚠️ Offline mode / Firebase Init Error: $e");
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
  final List<String> lottoGames = ['3D', '2D', '4D', '6D', '6-42', '6-45', '6-49', '6-55', '6-58'];
  
  String selectedGameFreq = '3D'; 
  List<int> generatedNumbers = [];

  // Live Screen Map states
  String cloudResult = "9-2-5";
  String history2pm = "9-5-2";
  String history5pm = "4-7-1";
  String history9pm = "3-0-8";
  String gameName = "3D Swertres";
  String jackpotPrize = "P4,500.00";

  @override
  void initState() {
    super.initState();
    _strategyTabController = TabController(length: strategies.length, vsync: this);
    _listenToFirestore(selectedGameFreq);
  }

  // Live Listener galing sa Cloud Firestore
  void _listenToFirestore(String game) {
    FirebaseFirestore.instance.collection('pcso_data').doc(game).snapshots().listen((snapshot) {
      if (!mounted) return;
      
      if (!snapshot.exists) {
        _checkBackupCollection(game);
        return;
      }

      _updateScreenData(game, snapshot.data());
    });
  }

  // Backup checker para sa 'results' collection mo
  void _checkBackupCollection(String game) {
    FirebaseFirestore.instance.collection('results').doc(game).snapshots().listen((snapshot) {
      if (!mounted || !snapshot.exists) {
        setState(() {
          gameName = game.contains('-') ? "$game Lotto" : "$game Game";
          jackpotPrize = "Milyong Piso Jackpot";
          if (game == '2D') { cloudResult = "00-00"; jackpotPrize = "P4,000.00"; }
          else if (game == '4D') { cloudResult = "0-0-0-0"; jackpotPrize = "P10,000.00+"; }
          else if (game == '6D') { cloudResult = "0-0-0-0-0-0"; jackpotPrize = "P150,000.00+"; }
          else { cloudResult = "00-00-00-00-00-00"; }
        });
        return;
      }
      _updateScreenData(game, snapshot.data());
    });
  }

  void _updateScreenData(String game, Map<String, dynamic>? data) {
    setState(() {
      if (game == '3D') {
        gameName = "3D Swertres";
        jackpotPrize = "P4,500.00";
        cloudResult = (data?['result'] ?? '9-2-5').toString();
        
        history2pm = (data?['2pm'] ?? data?['history_2pm'] ?? '9-5-2').toString();
        history5pm = (data?['5pm'] ?? data?['history_5pm'] ?? '4-7-1').toString();
        history9pm = (data?['9pm'] ?? data?['history_9pm'] ?? '3-0-8').toString();
      } else if (game == '2D') {
        gameName = "2D Lotto";
        jackpotPrize = "P4,000.00";
        cloudResult = (data?['result'] ?? '24-11').toString();
      } else if (game == '4D') {
        gameName = "4D Lotto";
        jackpotPrize = "Minimum P10,000.00";
        cloudResult = (data?['result'] ?? '1-2-3-4').toString();
      } else if (game == '6D') {
        gameName = "6D Lotto";
        jackpotPrize = "Minimum P150,000.00";
        cloudResult = (data?['result'] ?? '1-2-3-4-5-6').toString();
      } else {
        gameName = "$game Lotto";
        jackpotPrize = "Milyong Piso Jackpot";
        cloudResult = (data?['result'] ?? '00-00-00-00-00-00').toString();
      }
    });
  }

  void generateNumbers() {
    final random = Random();
    setState(() {
      if (selectedGameFreq == '3D') {
        List<int> pool = [5, 9, 2, 7, 0];
        generatedNumbers = List.generate(3, (_) => pool[random.nextInt(pool.length)]);
      } else if (selectedGameFreq == '2D') {
        generatedNumbers = List.generate(2, (_) => random.nextInt(31) + 1);
      } else if (selectedGameFreq == '4D') {
        generatedNumbers = List.generate(4, (_) => random.nextInt(10));
      } else if (selectedGameFreq == '6D') {
        generatedNumbers = List.generate(6, (_) => random.nextInt(10));
      } else {
        int maxNumber = int.parse(selectedGameFreq.split('-')[1]);
        Set<int> numbersSet = {};
        while (numbersSet.length < 6) {
          numbersSet.add(random.nextInt(maxNumber) + 1);
        }
        generatedNumbers = numbersSet.toList()..sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.adjust, color: Colors.redAccent, size: 20),
                SizedBox(width: 5),
                Text('LOTTO ASINTADO STRATEGY PRO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const Text('Developer: Renante Fullo', style: TextStyle(fontSize: 11, color: Colors.blueAccent)),
          ],
        ),
        bottom: TabBar(
          controller: _strategyTabController,
          isScrollable: true,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          tabs: strategies.map((strat) => Tab(text: strat.toUpperCase())).toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.cloud_done, color: Colors.green, size: 16),
                            SizedBox(width: 5), // NAITAMA NA! Tinanggal na ang "SAuthorized" typo
                            Text('FIRESTORE MONITOR ACTIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('$gameName | Live Data', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 12),
                        Text(cloudResult, style: const TextStyle(color: Colors.amber, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text('Jackpot: $jackpotPrize', style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (selectedGameFreq == '3D') ...[
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                        SizedBox(width: 5),
                        Text('PREVIOUS PCSO HISTORY (3D)', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHistoryBox('2 PM', history2pm),
                        _buildHistoryBox('5 PM', history5pm),
                        _buildHistoryBox('9 PM', history9pm),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade700, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedGameFreq,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E1E1E),
                        items: lottoGames.map((String game) {
                          return DropdownMenuItem<String>(
                            value: game,
                            child: Text('Digit Game: $game', style: const TextStyle(color: Colors.white, fontSize: 15)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGameFreq = value!;
                            generatedNumbers = []; 
                            _listenToFirestore(selectedGameFreq); 
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Center(
                    child: Text(
                      generatedNumbers.isEmpty 
                        ? 'Click Generate using Hot Frequency settings' 
                        : generatedNumbers.join(' - '),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: generatedNumbers.isEmpty ? Colors.grey.shade600 : Colors.amber,
                        fontSize: generatedNumbers.isEmpty ? 13 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: generateNumbers,
                child: const Text('GENERATE VIA Hot Frequency', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryBox(String time, String result) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            const Text('Today', style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(time, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(result, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
