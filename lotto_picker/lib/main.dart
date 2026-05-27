import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q', 
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
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('pcso_data/3D');
  
  final List<String> strategies = ['Hot Frequency', 'Odd/Even Balance', 'High/Low Range'];
  final List<String> lottoGames = ['6-58', '6-55', '6-49', '6-45', '6-42', '2D', '3D', '4D', '6D'];
  
  String selectedGameFreq = '3D'; 
  List<int> generatedNumbers = [];

  // Live variable states na sasalo sa Firebase data
  String cloudResult = "Loading...";
  String history2pm = "...";
  String history5pm = "...";
  String history9pm = "...";

  final List<int> pool = [5, 9, 2, 7, 0];

  @override
  void initState() {
    super.initState();
    _strategyTabController = TabController(length: strategies.length, vsync: this);
    _listenToFirebase();
  }

  // 📡 KONEKSYON: Dito na makikinig ang app mo nang LIVE sa database mo!
  void _listenToFirebase() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          cloudResult = data['result']?.toString() ?? '1-2-4';
          
          if (data['history'] != null) {
            final history = data['history'] as Map<dynamic, dynamic>;
            history2pm = history['2pm']?.toString() ?? '9-5-2';
            history5pm = history['5pm']?.toString() ?? '4-7-1';
            history9pm = history['9pm']?.toString() ?? '3-0-8';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _strategyTabController.dispose();
    super.dispose();
  }

  void generateNumbers() {
    final random = Random();
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
                Icon(Icons.track_changes, color: Colors.redAccent, size: 20),
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
                  // Cloud Monitor Active Card (GUMAGALAW NA!)
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
                        const Text('3D Swertres | Live Update', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 12),
                        Text(cloudResult, style: const TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
                        const SizedBox(height: 4),
                        const Text('Jackpot: P4,500.00', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Previous History Section (GUMAGALAW NA RIN!)
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
                    children: [
                      // 2 PM Box
                      Expanded(
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
                                child: const Text('2 PM', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Text(history2pm, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      // 5 PM Box
                      Expanded(
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
                                child: const Text('5 PM', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Text(history5pm, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      // 9 PM Box
                      Expanded(
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
                                child: const Text('9 PM', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Text(history9pm, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                      style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Generate Button
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
}
