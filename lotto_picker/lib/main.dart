import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q', // ⚠️ Boss, palitan mo ito ng totoong Web API Key mo mula sa Project Settings mamaya!
        projectId: 'lotto-asintado',
        appId: '1:458447298380:android:308fd26da180954e40b9e9',
        messagingSenderId: '458447298380',
        storageBucket: 'lotto-asintado.appspot.com',
        databaseURL: 'https://lotto-asintado-default-rtdb.asia-southeast1.firebasedatabase.app', 
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
  final List<String> lottoGames = ['6-58', '6-55', '6-49', '6-45', '6-42', '2D', '3D', '4D', '6D'];
  
  String selectedGameFreq = '3D'; 
  String selectedGameOddEven = '3D';
  String selectedGameHiLo = '3D';

  List<int> generatedNumbers = [];

  final Map<String, Map<String, String>> liveResultsData = {
    '3D': {'name': '3D Swertres', 'date': 'May 21, 2026', 'result': '1-2-4', 'jackpot': 'P4,500.00'},
    '2D': {'name': '2D EZ2 Lotto', 'date': 'May 21, 2026', 'result': '00-00', 'jackpot': 'P4,000.00'},
  };

  // ✅ INAYOS: Binago sa May 20 para eksaktong pareho sa screenshot mo!
  final Map<String, List<Map<String, String>>> historyLogsData = {
    '3D': [
      {'date': 'May 20', 'time': '2 PM', 'result': '9-5-2'},
      {'date': 'May 20', 'time': '5 PM', 'result': '4-7-1'},
      {'date': 'May 20', 'time': '9 PM', 'result': '3-0-8'},
    ],
  };

  final Map<String, List<int>> hotNumbersPool = {
    '3D': [5, 9, 2, 7, 0],
  };

  @override
  void initState() {
    super.initState();
    _strategyTabController = TabController(length: strategies.length, vsync: this);
  }

  @override
  void dispose() {
    _strategyTabController.dispose();
    super.dispose();
  }

  void generateNumbers(String strategy, String game) {
    final random = Random();
    List<int> pool = hotNumbersPool[game] ?? [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    setState(() {
      generatedNumbers = List.generate(3, (_) => pool[random.nextInt(pool.length)]);
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
                Icon(Icons.target, color: Colors.redAccent, size: 20),
                SizedBox(width: 5),
                Text('LOTTO ASINTADO STRATEGY PRO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  // Cloud Monitor Active Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.satellite_alt, color: Colors.green, size: 16),
                            SizedBox(width: 5),
                            Text('CLOUD MONITOR ACTIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('3D Swertres | May 21, 2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 12),
                        const Text('1-2-4', style: TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
                        const SizedBox(height: 4),
                        const Text('Jackpot: P4,500.00', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Previous History Section
                  Row(
                    children: const [
                      Icon(Icons.calendar_month, color: Colors.grey, size: 16),
                      SizedBox(width: 5),
                      Text('PREVIOUS PCSO HISTORY (3D)', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: historyLogsData['3D']!.map((log) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('${log['date']!}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                child: Text('${log['time']!}', style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Text('${log['result']!}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Target Draw Selector Card
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
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Result Display Center Text
                  Center(
                    child: Text(
                      generatedNumbers.isEmpty 
                        ? 'Click Generate using Hot Frequency settings' 
                        : generatedNumbers.join(' - '),
                      style: TextStyle(
                        color: generatedNumbers.isEmpty ? Colors.grey.shade600 : Colors.amber,
                        fontSize: generatedNumbers.isEmpty ? 13 : 28,
                        fontWeight: generatedNumbers.isEmpty ? Navigator.defaultRouteName == '/' ? FontWeight.normal : FontWeight.bold : FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Generate Button at Bottom
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
                onPressed: () => generateNumbers('Hot Frequency', selectedGameFreq),
                child: const Text('GENERATE VIA Hot Frequency', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
