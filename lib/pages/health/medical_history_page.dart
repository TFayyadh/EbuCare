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
      // Similar vibe as GrowthSummaryPage (subtle date line)
      // You can adjust format if you want.
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
      backgroundColor: const Color(0xFF2D3140), // same as GrowthSummaryPage
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FAE67), // same as GrowthSummaryPage
        title: const Text(
          "Medical Records",
          style: TextStyle(fontFamily: "Calsans"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E8B57),
        onPressed: _openAdd,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _svc.fetchMedicalEntries(),
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

              final medication = (e['medication'] ?? '').toString();
              final temp = (e['temperature'] ?? '').toString();
              final notes = (e['notes'] ?? '').toString();

              // Build a "parts" line similar to GrowthSummaryPage
              final parts = <String>[];
              if (medication.isNotEmpty) parts.add("Medication: $medication");
              if (temp.isNotEmpty) parts.add("Temp: $temp");

              final mainLine =
                  parts.isEmpty ? "Medical entry" : parts.join(" • ");

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
                      // subtle time line (like Growth date)
                      if (e['entry_time'] != null)
                        Text(
                          _prettyTime(e['entry_time']),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: "Raleway",
                            fontSize: 12,
                          ),
                        ),
                      if (e['entry_time'] != null) const SizedBox(height: 6),

                      // main values line
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
