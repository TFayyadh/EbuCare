import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
            itemCount: records.length + 1, // +1 for charts
            itemBuilder: (context, i) {
              // ✅ Chart section at the top
              if (i == 0) {
                return Column(
                  children: [
                    GrowthCharts(records: records),
                    const SizedBox(height: 14),
                  ],
                );
              }

              final r = records[i - 1];

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

/// =======================
/// Charts (Weight/Height/Head)
/// =======================
class GrowthCharts extends StatefulWidget {
  final List<Map<String, dynamic>> records;
  const GrowthCharts({super.key, required this.records});

  @override
  State<GrowthCharts> createState() => _GrowthChartsState();
}

class _GrowthChartsState extends State<GrowthCharts> {
  int _tab = 0; // 0=weight, 1=height, 2=head

  @override
  Widget build(BuildContext context) {
    final weight = _buildSeries(widget.records, _GrowthMetric.weightKg);
    final height = _buildSeries(widget.records, _GrowthMetric.heightCm);
    final head = _buildSeries(widget.records, _GrowthMetric.headCm);

    final showing = _tab == 0
        ? weight
        : _tab == 1
            ? height
            : head;

    final title = _tab == 0
        ? 'Weight (kg) trend'
        : _tab == 1
            ? 'Height (cm) trend'
            : 'Head Circumference (cm) trend';

    final unit = _tab == 0
        ? 'kg'
        : _tab == 1
            ? 'cm'
            : 'cm';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF222533),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + tabs
          Row(
            children: [
              const Icon(Icons.show_chart, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _miniTab('Weight',
                  selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _miniTab('Height',
                  selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
              const SizedBox(width: 8),
              _miniTab('Head',
                  selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
            ],
          ),
          const SizedBox(height: 12),

          if (showing.length < 2)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  "Not enough data for a chart yet.\n(Add 2+ records)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  // ✅ Android: tap/drag tooltip
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 10,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.round();
                          final dt = showing[idx].date.toLocal();
                          final dateLabel = DateFormat.yMMMd().format(dt);
                          return LineTooltipItem(
                            '$dateLabel\n${spot.y.toStringAsFixed(1)} $unit',
                            const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _bottomInterval(showing.length),
                        getTitlesWidget: (value, meta) {
                          final idx = value.round();
                          if (idx < 0 || idx >= showing.length)
                            return const SizedBox.shrink();
                          final dt = showing[idx].date.toLocal();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${dt.day}/${dt.month}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      dotData: const FlDotData(show: true), // ✅ easier to tap
                      spots: [
                        for (int i = 0; i < showing.length; i++)
                          FlSpot(i.toDouble(), showing[i].value),
                      ],
                    ),
                  ],
                  minY: _minY(showing),
                  maxY: _maxY(showing),
                ),
              ),
            ),

          const SizedBox(height: 10),
          _statsRow(showing, unit: unit),
        ],
      ),
    );
  }

  Widget _miniTab(String text,
      {required bool selected, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7FAE67) : const Color(0xFF3B3F4E),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _statsRow(List<_GrowthPoint> pts, {required String unit}) {
    if (pts.isEmpty) return const SizedBox.shrink();

    final last = pts.last.value;

    return Row(
      children: [
        Expanded(
          child: _miniStatCard(
            label: 'Latest',
            value: '${last.toStringAsFixed(1)} $unit',
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B3F4E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  static double _bottomInterval(int n) {
    if (n <= 6) return 1;
    if (n <= 12) return 2;
    if (n <= 20) return 3;
    return 4;
  }

  static double _minY(List<_GrowthPoint> pts) {
    final minV = pts.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    return (minV - 1).clamp(0, double.infinity);
  }

  static double _maxY(List<_GrowthPoint> pts) {
    final maxV = pts.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxV + 1;
  }

  static List<_GrowthPoint> _buildSeries(
    List<Map<String, dynamic>> records,
    _GrowthMetric metric,
  ) {
    final out = <_GrowthPoint>[];

    for (final r in records) {
      final recordedAt = r['recorded_at'];
      if (recordedAt == null) continue;

      final dt = DateTime.tryParse(recordedAt.toString());
      if (dt == null) continue;

      final v = _extractMetric(r, metric);
      if (v == null) continue;

      out.add(_GrowthPoint(date: dt, value: v));
    }

    // records loaded DESC, chart needs ASC
    out.sort((a, b) => a.date.compareTo(b.date));

    // last 14 points
    if (out.length > 14) return out.sublist(out.length - 14);
    return out;
  }

  static double? _extractMetric(Map<String, dynamic> r, _GrowthMetric metric) {
    dynamic raw;
    if (metric == _GrowthMetric.weightKg) raw = r['weight_kg'];
    if (metric == _GrowthMetric.heightCm) raw = r['height_cm'];
    if (metric == _GrowthMetric.headCm) raw = r['head_cm'];

    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }
}

enum _GrowthMetric { weightKg, heightCm, headCm }

class _GrowthPoint {
  final DateTime date;
  final double value;
  _GrowthPoint({required this.date, required this.value});
}

/// =======================
/// Photo (unchanged)
/// =======================
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
