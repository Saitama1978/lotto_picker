import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      ),
    );
  } catch (e) {
    print("⚠️ Firebase Init Error: $e");
  }
  runApp(const LottoAsintadoApp());
}

class LottoAsintadoApp extends StatelessWidget {
  const LottoAsintadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lotto Asintado Strategy Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D11),
        primaryColor: const Color(0xFFFFD700),
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
  late TabController _navTabController;
  final List<String> lottoGames = ['6/42', '6/45', '6/49', '6/55', '6/58', '3D', '2D', '4D', '6D'];
  
  String selectedGame = '6/42';
  String selectedZodiac = 'Zodiac';
  final TextEditingController _birthYearController = TextEditingController(text: '1951');
  
  List<List<int>> generatedCombinations = [];
  String cloudResult = "00-00-00-00-00-00";
  String jackpotPrize = "P35,500,000";

  @override
  void initState() {
    super.initState();
    _navTabController = TabController(length: 4, vsync: this, initialIndex: 2);
  }

  void calculateCombinations() {
    final random = Random();
    int gameMax = 42;
    if (selectedGame == '6/45') gameMax = 45;
    if (selectedGame == '6/49') gameMax = 49;
    if (selectedGame == '6/55') gameMax = 55;
    if (selectedGame == '6/58') gameMax = 58;

    List<List<int>> tempCombi = [];
    
    // Generate 4 premium rows like the screenshot
    for (int i = 0; i < 4; i++) {
      Set<int> numSet = {};
      if (selectedGame.contains('D')) {
        int digits = int.parse(selectedGame.replaceAll('D', ''));
        List<int> dList = List.generate(digits, (_) => random.nextInt(10));
        tempCombi.add(dList);
      } else {
        while (numSet.length < 5) { // Pinapakita sa screenshot ay 5 balls kada row
          numSet.add(random.nextInt(gameMax) + 1);
        }
        tempCombi.add(numSet.toList()..sort());
      }
    }

    setState(() {
      generatedCombinations = tempCombi;
    });
  }

  @override
  Widget build(BuildContext context) {
    // I-convert ang '6/42' sa '6-42' para tumugma sa Firestore IDs mo
    String docId = selectedGame.replaceAll('/', '-');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161F),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white54),
        actions: const [
          Icon(Icons.crop_free, color: Colors.white54),
          SizedBox(width: 15),
          Icon(Icons.settings, color: Colors.white54),
          SizedBox(width: 15),
        ],
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.stars, color: Color(0xFFFFD700), size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('LOTTO ASINTADO STRATEGY PRO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                Text('Developer: Renante Fullo', style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _navTabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.white38,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt, size: 20), text: 'MY COMBINATIONS'),
            Tab(icon: Icon(Icons.local_fire_department, size: 20), text: 'HOT NUMBERS'),
            Tab(icon: Icon(Icons.menu_book, size: 20), text: 'STRATEGY GUIDE'),
            Tab(icon: Icon(Icons.history, size: 20), text: 'MY HISTORY'),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('pcso_data').doc(docId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            cloudResult = (data['result'] ?? data['numbers'] ?? '00-00-00').toString();
            jackpotPrize = (data['jackpot'] ?? 'P0.00').toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Live Estimated Jackpot Display Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF231B15), Color(0xFF16161F)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.2), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                        child: Text(selectedGame, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next Draw: $selectedGame Lotto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            const Text('Current Estimated Jackpot', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(jackpotPrize, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selector Control Row (Dropdown & Buttons)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGame,
                            dropdownColor: const Color(0xFF16161F),
                            isExpanded: true,
                            items: lottoGames.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setState(() => selectedGame = v!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.trending_up, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.bar_chart, color: Colors.grey, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Middle Row: Frequency Chart & Lucky Generator Inputs
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Hot Number Frequency Chart
                    Expanded(
                      child: Container(
                        height: 175,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hot Number Frequency', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (val, _) => Text((val.toInt() + 1).toString(), style: const TextStyle(fontSize: 9, color: Colors.white30)),
                                      ),
                                    ),
                                  ),
                                  barGroups: [
                                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 45, color: Colors.pinkAccent, width: 8)]),
                                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 38, color: Colors.orangeAccent, width: 8)]),
                                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 32, color: Colors.greenAccent, width: 8)]),
                                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 35, color: Colors.blueAccent, width: 8)]),
                                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 30, color: Colors.purpleAccent, width: 8)]),
                                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 18, color: Colors.deepPink, width: 8)]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right Column - Input Configuration Fields
                    Expanded(
                      child: Container(
                        height: 175,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Lucky Combination Generator', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            
                            // Zodiac Dropdown Field
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: const Color(0xFF0D0D11), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedZodiac,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF16161F),
                                  items: ['Zodiac', 'Aries', 'Leo', 'Pisces'].map((z) => DropdownMenuItem(value: z, child: Text(z, style: const TextStyle(fontSize: 12)))).toList(),
                                  onChanged: (v) => setState(() => selectedZodiac = v!),
                                ),
                              ),
                            ),

                            // Birth Year Input Field
                            SizedBox(
                              height: 38,
                              child: TextField(
                                controller: _birthYearController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  labelText: 'Birth Year',
                                  labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                                  filled: true,
                                  fillColor: const Color(0xFF0D0D11),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white10)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.amber)),
                                ),
                              ),
                            ),

                            // Calculate Button Action
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF251E18),
                                  side: const BorderSide(color: Color(0xFF5E4934)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: calculateCombinations,
                                child: const Text('Calculate', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bottom Generated Combination Output List View
                if (generatedCombinations.isNotEmpty)
                  ...generatedCombinations.map((combination) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                children: combination.map((num) => Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: Color(0xFF262633), shape: BoxShape.circle),
                                      child: Text(num.toString().padLeft(2, '0'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700), fontSize: 13)),
                                    )).toList(),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text('94%内容', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('Match', style: TextStyle(color: Colors.white38, fontSize: 9)),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF262633), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white10)),
                              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white10)),
        onPressed: calculateCombinations,
        child: const Icon(Icons.add, color: Color(0xFFFFD700)),
      ),
    );
  }
}
