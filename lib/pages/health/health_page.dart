import 'package:flutter/material.dart';
import '../../service/health_supabase_service.dart';
import 'medical_history_page.dart';
import 'vaccine_history_page.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final _svc = HealthSupabaseService();
  late Future<_Counts> _countsFuture;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    _countsFuture = _fetchCounts();
  }

  Future<_Counts> _fetchCounts() async {
    final medical = await _svc.countMedicalEntries();
    final vaccine = await _svc.countVaccineEntries();
    return _Counts(medical: medical, vaccine: vaccine);
  }

  Future<void> _openMedical() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicalHistoryPage()),
    );
    setState(_loadCounts);
  }

  Future<void> _openVaccine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VaccineHistoryPage()),
    );
    setState(_loadCounts);
  }

  @override
  Widget build(BuildContext context) {
    final bg = Colors.pink.shade100; // same as BabyGrowthHomePage

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 247, 226, 226),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Health",
          style: TextStyle(
            fontFamily: "Calsans",
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<_Counts>(
          future: _countsFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Center(
                child: Text(
                  "Failed to load data\n${snap.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "Raleway",
                    color: Colors.black87,
                  ),
                ),
              );
            }

            final data = snap.data!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionCard(
                  title: "Medical",
                  color: Color.fromARGB(
                      255, 205, 222, 158), // matches Growth green vibe
                  onAdd: _openMedical, // + opens medical
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${data.medical} record${data.medical == 1 ? "" : "s"} stored",
                            style: const TextStyle(
                              fontFamily: "Raleway",
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: data.medical == 0 ? null : _openMedical,
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
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: "Vaccine",
                  color: Color.fromARGB(
                      255, 205, 222, 158), // matches Milestones purple/grey
                  onAdd: _openVaccine, // + opens vaccine
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${data.vaccine} record${data.vaccine == 1 ? "" : "s"} stored",
                            style: const TextStyle(
                              fontFamily: "Raleway",
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: data.vaccine == 0 ? null : _openVaccine,
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
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// SAME card UI style as BabyGrowthHomePage
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
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
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Counts {
  final int medical;
  final int vaccine;
  _Counts({required this.medical, required this.vaccine});
}
