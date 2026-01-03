import 'package:ebucare_app/pages/checkin_sleep_page.dart';
import 'package:flutter/material.dart';

class CheckinEmotionalPage extends StatefulWidget {
  final List<String> physicalSelections;
  const CheckinEmotionalPage({super.key, required this.physicalSelections});

  @override
  State<CheckinEmotionalPage> createState() => _CheckinEmotionalPageState();
}

class _CheckinEmotionalPageState extends State<CheckinEmotionalPage> {
  final TextEditingController _othersCtrl = TextEditingController();

  // Emotions (from your screenshot)
  final List<String> _emotions = const [
    'Happy',
    'Excited',
    'Hopeful',
    'Empowered',
    'Grateful',
    'Blessed',
    'Loved',
    'Proud',
    'Confident',
    'Anxious',
    'Overwhelmed',
    'Tired',
    'Frustrated',
    'Lonely',
    'Sad',
    'Insecure',
    'Irritable',
    'Unstable',
  ];

  final Set<String> _selected = {};

  @override
  void dispose() {
    _othersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pinkBg = Color(0xFFFFE6EC);
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
                      'EMOTIONAL WELL-\nBEING',
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
                    const Text('Emotions',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    // Chip grid
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _emotions.map((e) {
                        final selected = _selected.contains(e);
                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setState(() {
                            selected ? _selected.remove(e) : _selected.add(e);
                          }),
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

  void _finish() async {
    final emotional = [..._selected];
    final others = _othersCtrl.text.trim();
    if (others.isNotEmpty) emotional.add(others);

    final payloadSoFar = {
      'physical': widget.physicalSelections,
      'emotional': emotional,
    };

    final finalResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckinSleepPage(collected: payloadSoFar),
      ),
    );

    if (finalResult != null && mounted) {
      Navigator.pop(
          context, finalResult); // return to the first page with everything
    }
  }
}
