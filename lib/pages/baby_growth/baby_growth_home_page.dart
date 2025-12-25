import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../service/baby_age_service.dart';
import 'growth_add_record_page.dart';
import 'growth_summary_page.dart';
import 'milestones_page.dart';

class BabyGrowthHomePage extends StatefulWidget {
  const BabyGrowthHomePage({super.key});

  @override
  State<BabyGrowthHomePage> createState() => _BabyGrowthHomePageState();
}

class _BabyGrowthHomePageState extends State<BabyGrowthHomePage> {
  final supabase = Supabase.instance.client;

  Future<int> _loadGrowthCount() async {
    final user = supabase.auth.currentUser!;
    // Using select + count. Some supabase versions return count via response metadata;
    // this method works reliably by just counting the returned list.
    final data = await supabase
        .from('baby_growth_records')
        .select('id')
        .eq('user_id', user.id);

    return (data as List).length;
  }

  @override
  Widget build(BuildContext context) {
    final bg = Colors.pink.shade100;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Baby Growth & Milestones",
            style: TextStyle(fontFamily: "Calsans")),
        backgroundColor: bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: "Growth",
              color: const Color(0xFF7FAE67),
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GrowthAddRecordPage()),
                ).then((_) {
                  if (mounted) setState(() {});
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<int>(
                  future: _loadGrowthCount(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Text(
                        "Failed to load records",
                        style: const TextStyle(
                            fontFamily: "Raleway", color: Colors.white),
                      );
                    }

                    final count = snap.data ?? 0;

                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            "$count record${count == 1 ? "" : "s"} stored",
                            style: const TextStyle(
                              fontFamily: "Raleway",
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // ✅ View summary button
                        TextButton(
                          onPressed: count == 0
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GrowthSummaryPage(),
                                    ),
                                  );
                                },
                          child: const Text(
                            "View",
                            style: TextStyle(
                              fontFamily: "Raleway",
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: "Milestones",
              color: const Color(0xFF9EA0B8),
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MilestonesPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<BabyAge>(
                  future: BabyAgeService(supabase).getBabyAge(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Text("Loading baby age...",
                          style: TextStyle(
                              fontFamily: "Raleway", color: Colors.white));
                    }
                    if (snap.hasError) {
                      return Text(
                        "Baby birthdate not found. Please complete onboarding.\n${snap.error}",
                        style: const TextStyle(
                            fontFamily: "Raleway", color: Colors.white),
                      );
                    }
                    final age = snap.data!;
                    return Text(
                      "Current baby age: ${age.ageMonths} months (${age.ageDays} days)\nTap + to track completed milestones.",
                      style: const TextStyle(
                        fontFamily: "Raleway",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Color color,
    required Widget child,
    required VoidCallback onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B3F4E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                        fontFamily: "Calsans",
                        fontSize: 22,
                      )),
                ),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8E62),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
