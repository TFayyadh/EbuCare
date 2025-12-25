import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class GrowthSummaryPage extends StatelessWidget {
  const GrowthSummaryPage({super.key});

  Future<List<Map<String, dynamic>>> _loadRecords() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser!;

    final data = await supabase
        .from('baby_growth_records')
        .select()
        .eq('user_id', user.id)
        .order('recorded_at', ascending: false);

    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3140),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FAE67),
        title: const Text(
          "Growth Records",
          style: TextStyle(fontFamily: "Calsans"),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadRecords(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
            return const Center(
              child: Text(
                "No records yet",
                style: TextStyle(color: Colors.white, fontFamily: "Raleway"),
              ),
            );
          }

          final records = snap.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, i) {
              final r = records[i];

              final parts = <String>[];
              if (r['weight_kg'] != null) {
                parts.add("Weight: ${r['weight_kg']} kg");
              }
              if (r['height_cm'] != null) {
                parts.add("Height: ${r['height_cm']} cm");
              }
              if (r['head_cm'] != null) {
                parts.add("Head: ${r['head_cm']} cm");
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B3F4E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Date shown first (subtle)
                    if (r['recorded_at'] != null)
                      Text(
                        DateFormat.yMMMEd()
                            .format(DateTime.parse(r['recorded_at'])),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: "Raleway",
                          fontSize: 12,
                        ),
                      ),

                    if (r['recorded_at'] != null) const SizedBox(height: 6),

                    // ✅ Growth values
                    Text(
                      parts.isEmpty ? "No values recorded" : parts.join(" • "),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // ✅ Photo preview
                    if (r['photo_path'] != null) ...[
                      const SizedBox(height: 10),
                      _GrowthPhoto(path: r['photo_path']),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GrowthPhoto extends StatelessWidget {
  final String path;
  const _GrowthPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return FutureBuilder<String>(
      future: supabase.storage.from('baby-growth').createSignedUrl(path, 60),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox();

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            snap.data!,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
