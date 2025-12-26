import 'package:flutter/material.dart';
import '../../service/health_supabase_service.dart';
import 'vaccine_entry_page.dart';

class VaccineHistoryPage extends StatefulWidget {
  const VaccineHistoryPage({super.key});

  @override
  State<VaccineHistoryPage> createState() => _VaccineHistoryPageState();
}

class _VaccineHistoryPageState extends State<VaccineHistoryPage> {
  final _svc = HealthSupabaseService();

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VaccineEntryPage()),
    );
    setState(() {});
  }

  Future<void> _openEdit(Map<String, dynamic> entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VaccineEntryPage(existing: entry)),
    );
    setState(() {});
  }

  String _prettyDate(dynamic d) {
    // entry_date comes as "YYYY-MM-DD"
    final s = d.toString();
    if (s.length >= 10) {
      final y = s.substring(0, 4);
      final m = s.substring(5, 7);
      final day = s.substring(8, 10);
      return "$day/$m/$y";
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2430),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBack(title: "Vaccine", onBack: () => Navigator.pop(context)),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _svc.fetchVaccineEntries(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snap.error}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        "No vaccine entries yet.",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFF2D3446)),
                    itemBuilder: (_, i) {
                      final e = list[i];
                      final vaccine = (e['vaccine'] ?? '').toString();
                      final notes = (e['notes'] ?? '').toString();

                      return InkWell(
                        onTap: () => _openEdit(e),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2F3D),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vaccine.isEmpty ? "Medical Entry" : vaccine,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Serif',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${_prettyDate(e['entry_time'])}",
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 14),
                              ),
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  notes,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E8B57),
        onPressed: _openAdd,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class _HeaderBack extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _HeaderBack({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(color: Color(0xFFB8B6D6)),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black87,
                  fontFamily: 'Serif',
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
