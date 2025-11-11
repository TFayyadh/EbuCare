import 'package:flutter/material.dart';
import 'home_page.dart'; // <-- change to your actual home page file name

class CheckinSummaryPage extends StatelessWidget {
  /// Each entry is a map like: { 'payload': {...}, 'created_at': '2025-06-06T08:00:00Z' }
  final List<Map<String, dynamic>> entries;
  const CheckinSummaryPage({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    const pinkBg = Color(0xFFFFE6EC);

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
                children: const [
                  BackButton(),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'SUMMARY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 6, top: 2),
                    child: Icon(Icons.self_improvement_outlined, size: 48),
                  )
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final createdAt =
                      DateTime.tryParse('${entries[i]['created_at']}');
                  final payload =
                      Map<String, dynamic>.from(entries[i]['payload'] ?? {});
                  final dateStr = _formatDate(createdAt);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _SummaryCard(payload: payload),
                    ],
                  );
                },
              ),
            ),

            // Continue (you can navigate somewhere else)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () {
                    // Navigate to Home and clear all previous pages
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const HomePage()), // change widget name if needed
                      (route) => false, // remove all previous routes
                    );
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF7ECF),
                          Color(0xFFF76BB6),
                          Color(0xFFEE62AE)
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Continue',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    final dd = d.day.toString();
    final mm = d.month.toString();
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }
}

class _SummaryCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _SummaryCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFFEEC5D7); // soft pink/purple like mock
    final physical = List<String>.from(payload['physical'] ?? const []);
    final emotional = List<String>.from(payload['emotional'] ?? const []);

    final sleep = Map<String, dynamic>.from(payload['sleep'] ?? const {});
    final nutrition =
        Map<String, dynamic>.from(payload['nutrition'] ?? const {});
    final vitamins = Map<String, dynamic>.from(payload['vitamins'] ?? const {});

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 13.5, color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (physical.isNotEmpty) ...[
              const _Label('Physical Symptoms'),
              Text(physical.join(', ')),
              const SizedBox(height: 8),
            ],
            if (emotional.isNotEmpty) ...[
              const _Label('Emotions'),
              Text(emotional.join(', ')),
              const SizedBox(height: 8),
            ],
            if (sleep.isNotEmpty) ...[
              const _Label('Sleep & Rest'),
              Text('Quality: ${sleep['quality'] ?? '-'}'),
              Text('Hours: ${sleep['hours'] ?? '-'}'),
              if (sleep['impacts'] != null)
                Text(
                    'Impacts: ${List<String>.from(sleep['impacts']).join(', ')}'),
              const SizedBox(height: 8),
            ],
            if (nutrition.isNotEmpty) ...[
              const _Label('Nutrition & Hydration'),
              Text('Meals: ${nutrition['meals'] ?? '-'}'),
              Text('Appetite: ${nutrition['appetite'] ?? '-'}'),
              Text(
                  'Water: ${nutrition['water_ml'] != null ? '${nutrition['water_ml']} ml' : '-'}'),
              if (nutrition['others'] != null)
                Text('Others: ${nutrition['others']}'),
              const SizedBox(height: 8),
            ],
            if (vitamins.isNotEmpty) ...[
              const _Label('Vitamins & Supplements'),
              Text('Took today: ${_yesNo(vitamins['took_today'])}'),
              if (vitamins['type'] != null) Text('Type: ${vitamins['type']}'),
            ],
          ],
        ),
      ),
    );
  }

  static String _yesNo(dynamic v) {
    if (v == true) return 'Yes';
    if (v == false) return 'No';
    return '-';
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}
