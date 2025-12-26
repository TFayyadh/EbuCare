import 'package:flutter/material.dart';
import '../../service/health_supabase_service.dart';
import 'medical_entry_page.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  final _svc = HealthSupabaseService();

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicalEntryPage()),
    );
    setState(() {}); // refresh after returning
  }

  Future<void> _openEdit(Map<String, dynamic> entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicalEntryPage(existing: entry)),
    );
    setState(() {});
  }

  String _prettyTime(dynamic iso) {
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return "${dt.day}/${dt.month}/${dt.year}  $h:$m $ampm";
    } catch (_) {
      return iso.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2430),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBack(title: "Medical", onBack: () => Navigator.pop(context)),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _svc.fetchMedicalEntries(),
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
                        "No medical entries yet.",
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
                      final medication = (e['medication'] ?? '').toString();
                      final temp = (e['temperature'] ?? '').toString();
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
                                medication.isEmpty
                                    ? "Medical Entry"
                                    : medication,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Serif',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${_prettyTime(e['entry_time'])}"
                                "${temp.isEmpty ? "" : " • Temp: $temp"}",
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
