import 'package:ebucare_app/pages/checkin_emotional_page.dart';
import 'package:flutter/material.dart';

class CheckinPhysicalPage extends StatefulWidget {
  const CheckinPhysicalPage({super.key});

  @override
  State<CheckinPhysicalPage> createState() => _CheckinPhysicalPageState();
}

class _CheckinPhysicalPageState extends State<CheckinPhysicalPage> {
  final TextEditingController _othersCtrl = TextEditingController();

  // List of postpartum symptoms
  final List<String> _symptoms = [
    'Fatigue',
    'Headaches',
    'Body Aches',
    'Muscle Pain',
    'Soreness',
    'Heavy Bleeding',
    'Night Sweats',
    'Hot Flashes',
    'Breast Pain',
    'Clogged Milk Ducts',
    'Nipple Pain',
    'Hemorrhoids',
    'Urinary Incontinence',
    'Constipation',
    'Diarrhea',
    'Pelvic Pain',
    'Lower Back Pain',
    'Hair Loss',
  ];

  final Set<String> _selectedSymptoms = {};

  @override
  void dispose() {
    _othersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFFFE6EC);
    const primaryPink = Color(0xFFF76BB6);

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
                color: pink,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PHYSICAL HEALTH',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Postpartum Symptoms',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _symptoms.map((s) {
                        final selected = _selectedSymptoms.contains(s);
                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.remove(s);
                              } else {
                                _selectedSymptoms.add(s);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFFF0F6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selected
                                    ? primaryPink
                                    : const Color(0xFFDADADA),
                                width: 1.6,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: primaryPink.withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 13.5),
                            ),
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

            // Continue button
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
                  onPressed: _onContinue,
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

  void _onContinue() async {
    final selected = [..._selectedSymptoms];
    final others = _othersCtrl.text.trim();
    if (others.isNotEmpty) selected.add(others);

    // Go to Emotional page and wait for final result (optional)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckinEmotionalPage(physicalSelections: selected),
      ),
    );

    if (result != null) {
      // Do something with the combined result (e.g., save/send)
      // result is a Map<String, dynamic>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved! ${result.toString()}')),
      );
    }
  }
}
