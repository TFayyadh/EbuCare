import 'package:ebucare_app/pages/checkin_supplement_page.dart';
import 'package:flutter/material.dart';

class CheckinNutritionPage extends StatefulWidget {
  final Map<String, dynamic> collected; // physical + emotional + sleep
  const CheckinNutritionPage({super.key, required this.collected});

  @override
  State<CheckinNutritionPage> createState() => _CheckinNutritionPageState();
}

class _CheckinNutritionPageState extends State<CheckinNutritionPage> {
  // Single-select options
  final List<String> _meals = const ['1', '2', '3', '4+'];
  String? _mealsToday;

  final List<String> _appetite = const ['Poor', 'Normal', 'Good'];
  String? _appetiteToday;

  final List<int> _waterChoices = const [
    150,
    200,
    250,
    300,
    350,
    400,
    500
  ]; // ml
  int? _waterMl;

  final TextEditingController _othersCtrl = TextEditingController();

  @override
  void dispose() {
    _othersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pinkBg = Color(0xFFFFE6EC);
    const chipOn = Color(0xFF7AD68A); // soft green for this page
    const chipOnText = Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              decoration: const BoxDecoration(
                color: pinkBg,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'NUTRITION &\nHYDRATION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 6, top: 2),
                    child: Icon(Icons.self_improvement_outlined, size: 48),
                  )
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meals
                    const Text('How many meals did you have today?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _singleSelectChips(
                      options: _meals,
                      selected: _mealsToday,
                      onSelect: (v) => setState(() => _mealsToday = v),
                      borderColor: chipOn,
                    ),

                    const SizedBox(height: 24),
                    // Appetite
                    const Text('How would you describe your appetite today?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _singleSelectChips(
                      options: _appetite,
                      selected: _appetiteToday,
                      onSelect: (v) => setState(() => _appetiteToday = v),
                      borderColor: const Color(0xFFF76BB6), // soft pink
                    ),

                    const SizedBox(height: 24),
                    // Water
                    const Text('How much water did you drink today?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _waterChoices.map((ml) {
                        final selected = _waterMl == ml;
                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setState(() => _waterMl = ml),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEFFAF1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color:
                                    selected ? chipOn : const Color(0xFFDADADA),
                                width: 1.6,
                              ),
                            ),
                            child: Text('${ml}ml',
                                style: const TextStyle(
                                    fontSize: 13.5, color: chipOnText)),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text('Others:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _othersCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type here',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Continue
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Color.fromARGB(255, 205, 222, 158),
                  ),
                  onPressed: _finish,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Helpers ----
  Widget _singleSelectChips({
    required List<String> options,
    required String? selected,
    required void Function(String) onSelect,
    required Color borderColor,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((o) {
        final isSel = selected == o;
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onSelect(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFFEFFAF1) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSel ? borderColor : const Color(0xFFDADADA),
                width: 1.6,
              ),
            ),
            child: Text(o, style: const TextStyle(fontSize: 13.5)),
          ),
        );
      }).toList(),
    );
  }

  void _finish() async {
    final others = _othersCtrl.text.trim();

    final payloadSoFar = {
      ...widget.collected,
      'nutrition': {
        'meals': _mealsToday, // '1' | '2' | '3' | '4+'
        'appetite': _appetiteToday, // 'Poor' | 'Normal' | 'Good'
        'water_ml': _waterMl, // e.g., 300
        'others': others.isEmpty ? null : others,
      },
    };

    final finalResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckinSupplementPage(collected: payloadSoFar),
      ),
    );

    if (!mounted) return;
    if (finalResult != null) {
      Navigator.pop(context, finalResult); // bubble everything back to page 1
    }
  }
}
