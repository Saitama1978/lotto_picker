import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const LottoAsintadoPremiumApp());
}

class LottoAsintadoPremiumApp extends StatelessWidget {
  const LottoAsintadoPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lotto Asintado Strategy Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111115),
        primaryColor: const Color(0xFFE5A93C),
      ),
      home: const PremiumDashboardScreen(),
    );
  }
}

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen> {
  // States para sa mga interactive dropdowns at buttons
  String selectedGame = '6/42';
  String selectedZodiac = 'Zodiac';
  final TextEditingController _yearController = TextEditingController(text: '1951');
  int currentActiveTab = 2; // Strategy Guide ang default active base sa larawan mo

  // Mga default numbers na magbabago kapag pinindot ang Calculate
  List<List<int>> currentCombinations = [
    [11, 25, 38, 50, 67],
    [11, 25, 38, 50, 67],
    [11, 25, 38, 50, 67],
    [11, 25, 38, 50, 67],
  ];

  void _recalculateNumbers() {
    setState(() {
      // Ginagawa nitong dynamic ang mga bola base sa napiling laro
      int maxLimit = selectedGame == '6/42' ? 42 : (selectedGame == '6/45' ? 45 : 58);
      final uniqueSeed = DateTime.now().millisecondsSinceEpoch;
      
      currentCombinations = List.generate(4, (index) {
        List<int> combination = [];
        while (combination.length < 5) {
          int generatedNum = ((uniqueSeed + index * 11 + combination.length * 13) % maxLimit) + 1;
          if (!combination.contains(generatedNum)) {
            combination.add(generatedNum);
          }
        }
        combination.sort();
        return combination;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎯 New combinations generated for $selectedGame!'),
        backgroundColor: const Color(0xFF2C1C4D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR (Eksaktong Deep Purple na may Premium Gold Elements) ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF26183B),
        elevation: 8,
        shadowColor: Colors.black54,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () {},
        ),
        title: Row(
          children: [
            // Gintong Bituin Logo Placeholder
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5A93C).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5A93C), width: 1.5),
              ),
              child: const Icon(Icons.star, color: Color(0xFFE5A93C), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LOTTO ASINTADO STRATEGY PRO',
                    style: GoogleFonts.orbitron(
                      fontSize: 14, 
                      fontWeight: FontWeight.extrabold, 
                      color: Colors.white,
                      letterSpacing: 0.5
                    ),
                  ),
                  const Text(
                    'Developer: Renante Fullo', 
                    style: TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open, color: Colors.white70, size: 22), onPressed: () {}),
          IconButton(icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 22), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white70, size: 22), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Sub-header Navigation (Yung mga tabs sa ilalim ng header)
          Container(
            color: const Color(0xFF1E1233),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavigationTab(0, Icons.list_alt, 'MY COMBINATIONS'),
                _buildNavigationTab(1, Icons.local_fire_department, 'HOT NUMBERS'),
                _buildNavigationTab(2, Icons.menu_book, 'STRATEGY GUIDE'),
                _buildNavigationTab(3, Icons.history, 'MY HISTORY'),
              ],
            ),
          ),
          
          // Pangunahing scrollable area ng Dashboard
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // --- JACKPOT GRAND DISPLAY CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF241D15), Color(0xFF15151A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5A93C).withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        // Lotto Logo Badge
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D1614),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.redAccent, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              '6/42\nLOTTO',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Jackpot Texts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Next Draw: $selectedGame Lotto', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              const Text('Current Estimated Jackpot', style: TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(
                                '₱35,500,000',
                                style: GoogleFonts.robotoCondensed(
                                  color: const Color(0xFFE5A93C),
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- FILTERS ROW (Dropdown, Graph & Settings Icons) ---
                  Row(
                    children: [
                      // Interactive Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF181822),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGame,
                            dropdownColor: const Color(0xFF181822),
                            items: ['6/42', '6/45', '6/49', '6/55', '6/58'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedGame = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildSquareActionIcon(Icons.trending_up),
                      const SizedBox(width: 6),
                      _buildSquareActionIcon(Icons.bar_chart),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white54, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // --- SIDE-BY-SIDE PANELS (Chart & Luck Generator) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kaliwang Bahagi: Frequency Bar Chart
                      Expanded(
                        child: Container(
                          height: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16161C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hot Number Frequency', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildCustomBar(45, Colors.redAccent, '1'),
                                    _buildCustomBar(38, Colors.orangeAccent, '2'),
                                    _buildCustomBar(32, Colors.greenAccent, '3'),
                                    _buildCustomBar(34, Colors.blueAccent, '4'),
                                    _buildCustomBar(29, Colors.purpleAccent, '5'),
                                    _buildCustomBar(18, Colors.pinkAccent, '6'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Kanang Bahagi: Lucky Generator Inputs
                      Expanded(
                        child: Container(
                          height: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16161C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Lucky Combination Generator', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                              
                              // Zodiac Dropdown Field
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.black25,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedZodiac,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF16161C),
                                    style: const TextStyle(fontSize: 13, color: Colors.white),
                                    items: ['Zodiac', 'Aries', 'Taurus', 'Gemini', 'Leo'].map((String val) {
                                      return DropdownMenuItem<String>(value: val, child: Text(val));
                                    }).toList(),
                                    onChanged: (v) => setState(() => selectedZodiac = v!),
                                  ),
                                ),
                              ),

                              // Birth Year Input Field
                              SizedBox(
                                height: 38,
                                child: TextField(
                                  controller: _yearController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                    filled: true,
                                    fillColor: Colors.black25,
                                    labelText: 'Birth Year',
                                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white12)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE5A93C))),
                                  ),
                                ),
                              ),

                              // Interactive Calculate Button
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: _recalculateNumbers,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E1812),
                                    side: const BorderSide(color: Color(0xFFE5A93C), width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('Calculate', style: TextStyle(color: Color(0xFFE5A93C), fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- LIST OF GENERATED BALL COMBINATIONS ---
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentCombinations.length,
                    itemBuilder: (context, index) {
                      return _buildPremiumLottoRow(currentCombinations[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Plus Button (May gintong glow ring style)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF23163A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE5A93C), width: 1.5),
        ),
        onPressed: _recalculateNumbers,
        child: const Icon(Icons.add, color: Color(0xFFE5A93C), size: 28),
      ),
    );
  }

  // Helper Custom Widget para sa Navigation Sub-tabs
  Widget _buildNavigationTab(int index, IconData icon, String title) {
    bool isCurrent = currentActiveTab == index;
    return GestureDetector(
      onTap: () => setState(() => currentActiveTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          border: isCurrent ? const Border(bottom: BorderSide(color: Color(0xFFE5A93C), width: 2.5)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isCurrent ? const Color(0xFFE5A93C) : Colors.white30, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 9, 
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? const Color(0xFFE5A93C) : Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareActionIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF181822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, size: 18, color: Colors.white70),
    );
  }

  // Custom Minimalist Bar Chart Engine
  Widget _buildCustomBar(double heightPercentage, Color barColor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: heightPercentage * 2.2, // Scaling height factor
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38)),
      ],
    );
  }

  // --- PREMIUM COMBINATION ROW STYLE (Eksaktong Kopya ng UI Rows Mo) ---
  Widget _buildPremiumLottoRow(List<int> numbers) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14141A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Color(0xFFE5A93C), size: 16),
          const SizedBox(width: 8),
          
          // Render ng Limang Bilog na Bola
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: numbers.map((n) => Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF22222B),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    n.toString().padLeft(2, '0'),
                    style: const TextStyle(color: Color(0xFFE5A93C), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              )).toList(),
            ),
          ),
          
          const SizedBox(width: 8),
          // Percentage Match Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text('94%', style: TextStyle(color: Color(0xFFE5A93C), fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Match', style: TextStyle(fontSize: 8, color: Colors.white38)),
            ],
          ),
          const SizedBox(width: 10),
          
          // Save Button
          SizedBox(
            height: 28,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
