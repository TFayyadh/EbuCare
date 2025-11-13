import 'package:ebucare_app/pages/checkin_nutrition_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CheckinSleepPage extends StatefulWidget {
  final Map<String, dynamic> collected; // contains physical + emotional
  const CheckinSleepPage({super.key, required this.collected});

  @override
  State<CheckinSleepPage> createState() => _CheckinSleepPageState();
}

class _CheckinSleepPageState extends State<CheckinSleepPage> {
  // Single select: sleep quality
  final List<String> _qualityOptions = const [
    'Good',
    'Okay',
    'Bad',
    'Terrible'
  ];
  String? _quality;

  final int _minHours = 1;
  final int _maxHours = 24;

  // Hours slept (7–12 like screenshot vibe; default 8)
  int _hours = 8; // default
  late final List<int> _hourChoices = List<int>.generate(
    _maxHours - _minHours + 1,
    (i) => _minHours + i,
  ); // 4..13 (easy to tweak)

  // Multi-select: What impacted your sleep?
  final List<String> _impacts = const [
    'Physical Pain',
    'Partner',
    'Anxious',
    'Baby was fussy',
    'Night feedings',
  ];
  final Set<String> _selectedImpacts = {};

  final TextEditingController _othersCtrl = TextEditingController();

  @override
  void dispose() {
    _othersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pinkBg = Color(0xFFFFE6EC);
    const chipOn = Color(0xFFF76BB6);

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
                      'SLEEP & REST',
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
                    // How was your sleep?
                    const Text('How was your sleep?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _qualityOptions.map((q) {
                        final selected = _quality == q;
                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setState(() => _quality = q),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFFF0F6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color:
                                    selected ? chipOn : const Color(0xFFDADADA),
                                width: 1.6,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: chipOn.withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child:
                                Text(q, style: const TextStyle(fontSize: 13.5)),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    // How many hours?
                    const Text('How many hours did you sleep?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),

                    // iOS-like picker button that opens a CupertinoPicker
                    GestureDetector(
                      onTap: _showHourPicker,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFEEC5D7), // soft purple/pink card
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            '$_hours hours',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // What impacted your sleep?
                    const Text('What impacted your sleep?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _impacts.map((e) {
                        final selected = _selectedImpacts.contains(e);
                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setState(() {
                            selected
                                ? _selectedImpacts.remove(e)
                                : _selectedImpacts.add(e);
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEFFAF1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF7AD68A)
                                    : const Color(0xFFDADADA),
                                width: 1.6,
                              ),
                            ),
                            child:
                                Text(e, style: const TextStyle(fontSize: 13.5)),
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

            // Continue button (finish flow)
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
                    backgroundColor: Color.fromARGB(255, 255, 126, 207),
                  ),
                  onPressed: _completeFlow,
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

  void _showHourPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        int temp = _hours;
        // make sure initial item is in range
        final initialIndex = _hourChoices.indexOf(
          _hourChoices.contains(_hours)
              ? _hours
              : (_hours < _minHours ? _minHours : _maxHours),
        );

        return SizedBox(
          height: 260,
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text('Select hours',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const Divider(height: 16),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 36,
                  scrollController:
                      FixedExtentScrollController(initialItem: initialIndex),
                  onSelectedItemChanged: (i) => temp = _hourChoices[i],
                  children: _hourChoices
                      .map((h) => Center(
                          child: Text('$h ${h == 1 ? "hour" : "hours"}')))
                      .toList(),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _hours = temp); // will always be >= 1 now
                  Navigator.pop(ctx);
                },
                child: const Text('Done'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _completeFlow() async {
    final others = _othersCtrl.text.trim();
    final impacts = [..._selectedImpacts];
    if (others.isNotEmpty) impacts.add(others);

    final payloadSoFar = {
      ...widget.collected, // physical + emotional
      'sleep': {
        'quality': _quality,
        'hours': _hours,
        'impacts': impacts,
      },
    };

    final finalResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckinNutritionPage(collected: payloadSoFar),
      ),
    );

    if (!mounted) return;
    if (finalResult != null) {
      Navigator.pop(
          context, finalResult); // send everything back to the very first page
    }
  }
}
