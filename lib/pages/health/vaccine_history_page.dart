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
      backgroundColor: const Color(0xFF2D3140), // same as MedicalHistoryPage UI
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FAE67),
        title: const Text(
          "Vaccine Records",
          style: TextStyle(fontFamily: "Calsans"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E8B57),
        onPressed: _openAdd,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _svc.fetchVaccineEntries(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                "Error: ${snap.error}",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Raleway",
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "No records yet",
                style: TextStyle(color: Colors.white, fontFamily: "Raleway"),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final e = list[i];

              final vaccine = (e['vaccine'] ?? '').toString();
              final notes = (e['notes'] ?? '').toString();

              final parts = <String>[];
              if (vaccine.isNotEmpty) parts.add("Vaccine: $vaccine");

              final mainLine =
                  parts.isEmpty ? "Vaccine entry" : parts.join(" • ");

              return InkWell(
                onTap: () => _openEdit(e),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B3F4E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // subtle date line
                      if (e['entry_date'] != null)
                        Text(
                          _prettyDate(e['entry_date']),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: "Raleway",
                            fontSize: 12,
                          ),
                        ),
                      if (e['entry_date'] != null) const SizedBox(height: 6),

                      // main line
                      Text(
                        mainLine,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // notes
                      if (notes.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          notes,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: "Raleway",
                            fontSize: 14,
                          ),
                          maxLines: 3,
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
    );
  }
}
