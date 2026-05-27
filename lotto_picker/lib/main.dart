import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
  
  // 🎯 STRATEGY LIST: Idinagdag ang hiling mong Zodiac, Birth Year, at Date/Year!
  final List<String> strategies = ['Hot Frequency', 'Zodiac Guide', 'Birth Year Luck', 'Date & Year'];
  final List<String> lottoGames = ['3D', '2D', '4D', '6D', '6-42', '6-45', '6-49', '6-55', '6-58'];
  
  final List<String> zodiacSigns = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];

  String selectedGameFreq = '3D'; 
  String selectedStrategy = 'Hot Frequency';
  List<int> generatedNumbers = [];

  // Controllers para sa mga inputs ng user
  String selectedZodiac = 'Aries';
  final TextEditingController _birthYearController = TextEditingController(text: '1990');
  final TextEditingController _dateYearController = TextEditingController(text: '12-25-2026');

  // Firestore Live States
  String cloudResult = "9-2-5";
  String history2pm = "9-5-2";
  String history5pm = "4-7-1";
  String history9pm = "3-0-8";
  String date2pm = "Today";
  String date5pm = "Today";
  String date9pm = "Today";
  String gameName = "3D Swertres";
  String jackpotPrize = "P4,500.00";

  @override
  void initState() {
    super.initState();
    _strategyTabController = TabController(length: strategies.length, vsync: this);
    _strategyTabController.addListener(() {
      setState(() {
        selectedStrategy = strategies[_strategyTabController.index];
      });
    });
  }

  // 🧠 ALGORITHM NG MGA BAGONG DROPDOWNS AT INPUTS
  void generateNumbers() {
    final random = Random();
    int seedValue = random.nextInt(100); // Default random seed

    // 1. Kung Zodiac Guide ang napili
    if (selectedStrategy == 'Zodiac Guide') {
      seedValue = selectedZodiac.codeUnits.reduce((a, b) => a + b);
    } 
    // 2. Kung Birth Year Luck ang napili
    else if (selectedStrategy == 'Birth Year Luck') {
      int parsedYear = int.tryParse(_birthYearController.text) ?? 1990;
      seedValue = parsedYear;
    } 
    // 3. Kung Date & Year ang napili
    else if (selectedStrategy == 'Date & Year') {
      String cleanDate = _dateYearController.text.replaceAll('-', '');
      seedValue = int.tryParse(cleanDate) ?? 2026;
    }

    // Gamitin ang kalkuladong seed para maging asintado ang numerong ilalabas
    final seededRandom = Random(seedValue + random.nextInt(50));

    setState(() {
      int count = 6;
      int maxNum = 58;

      if (selectedGameFreq == '3D') {
        generatedNumbers = List.generate(3, (_) => seededRandom.nextInt(10));
        return;
      } else if (selectedGameFreq == '2D') {
        Set<int> numbersSet = {};
        while (numbersSet.length < 2) {
          numbersSet.add(seededRandom.nextInt(31) + 1);
        }
        generatedNumbers = numbersSet.toList();
        return;
      } else if (selectedGameFreq == '4D') {
        generatedNumbers = List.generate(4, (_) => seededRandom.nextInt(10));
        return;
      } else if (selectedGameFreq == '6D') {
        generatedNumbers = List.generate(6, (_) => seededRandom.nextInt(10));
        return;
      } else {
        maxNum = int.parse(selectedGameFreq.split('-')[1]);
        count = 6;
      }

      Set<int> numbersSet = {};
      while (numbersSet.length < count) {
        numbersSet.add(seededRandom.nextInt(maxNum) + 1);
      }
      generatedNumbers = numbersSet.toList()..sort();
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
                Icon(Icons.stars, color: Colors.amber, size: 20),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('pcso_data').doc(selectedGameFreq).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            String dbJackpot = (data['jackpot'] ?? '').toString();
            
            if (selectedGameFreq == '3D') {
              gameName = "3D Swertres";
              jackpotPrize = dbJackpot.isNotEmpty ? dbJackpot : "P4,500.00";
              cloudResult = (data['result'] ?? '9-2-5').toString();
              history2pm = (data['2pm'] ?? '9-5-2').toString();
              history5pm = (data['5pm'] ?? '4-7-1').toString();
              history9pm = (data['9pm'] ?? '3-0-8').toString();
              date2pm = (data['date_2pm'] ?? 'Today').toString();
              date5pm = (data['date_5pm'] ?? 'Today').toString();
              date9pm = (data['date_9pm'] ?? 'Today').toString();
            } else if (selectedGameFreq == '2D') {
              gameName = "2D Lotto";
              jackpotPrize = dbJackpot.isNotEmpty ? dbJackpot : "P4,000.00";
              cloudResult = (data['result'] ?? '24-11').toString();
            } else if (selectedGameFreq == '4D') {
              gameName = "4D Lotto";
              jackpotPrize = dbJackpot.isNotEmpty ? dbJackpot : "Minimum P10,000.00";
              cloudResult = (data['result'] ?? '1-2-3-4').toString();
            } else if (selectedGameFreq == '6D') {
              gameName = "6D Lotto";
              jackpotPrize = dbJackpot.isNotEmpty ? dbJackpot : "Minimum P150,000.00";
              cloudResult = (data['result'] ?? '1-2-3-4-5-6').toString();
            } else {
              gameName = "$selectedGameFreq Lotto";
              jackpotPrize = dbJackpot.isNotEmpty ? dbJackpot : "P20,000,000.00+";
              cloudResult = (data['result'] ?? '00-00-00-00-00-00').toString();
            }
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cloud Live Results Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.gpp_good, color: Colors.green, size: 16),
                                SizedBox(width: 5),
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
                            _buildHistoryBox('2 PM', history2pm, date2pm),
                            _buildHistoryBox('5 PM', history5pm, date5pm),
                            _buildHistoryBox('9 PM', history9pm, date9pm),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Game Selector Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade700)),
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
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 🎯 MGA DYNAMIC INPUTS BASE SA PINILING TAB / STRATEGY
                      if (selectedStrategy == 'Zodiac Guide') ...[
                        const Text('PILIIN ANG IYONG ZODIAC SIGN:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.blueAccent, width: 1.5)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedZodiac,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E1E1E),
                              items: zodiacSigns.map((String sign) {
                                return DropdownMenuItem<String>(value: sign, child: Text('Lucky Zodiac: $sign', style: const TextStyle(color: Colors.amber)));
                              }).toList(),
                              onChanged: (value) {
                                setState(() { selectedZodiac = value!; });
                              },
                            ),
                          ),
                        ),
                      ] else if (selectedStrategy == 'Birth Year Luck') ...[
                        const Text('IPASOK ANG TAON NG IYONG KAPANGANAKAN:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _birthYearController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.amber),
                          decoration: InputDecoration(
                            hintText: 'Halimbawa: 1995',
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            prefixIcon: const Icon(Icons.cake, color: Colors.blueAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.blueAccent)),
                          ),
                        ),
                      ] else if (selectedStrategy == 'Date & Year') ...[
                        const Text('IPASOK ANG PETSA NGAYON O PETSA NG BOLA (MM-DD-YYYY):', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dateYearController,
                          keyboardType: TextInputType.datetime,
                          style: const TextStyle(color: Colors.amber),
                          decoration: InputDecoration(
                            hintText: 'Format: 05-27-2026',
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            prefixIcon: const Icon(Icons.calendar_month, color: Colors.blueAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.blueAccent)),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 40),
                      
                      // Result Display
                      Center(
                        child: Text(
                          generatedNumbers.isEmpty 
                            ? 'Pindutin ang pindutan para mag-kalkula' 
                            : generatedNumbers.join(' - '),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: generatedNumbers.isEmpty ? Colors.grey.shade600 : Colors.amber,
                            fontSize: generatedNumbers.isEmpty ? 14 : 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Button
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
                    child: Text('GENERATE VIA $selectedStrategy', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryBox(String time, String result, String dateValue) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(time, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(result, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(dateValue, style: const TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
