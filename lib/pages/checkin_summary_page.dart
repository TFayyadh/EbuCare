import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_page.dart';

class CheckinSummaryPage extends StatefulWidget {
  const CheckinSummaryPage({super.key});

  @override
  State<CheckinSummaryPage> createState() => _CheckinSummaryPageState();
}

class _CheckinSummaryPageState extends State<CheckinSummaryPage> {
  bool _loading = true;
  String? _error;

  /// Each entry:
  /// { 'payload': {...}, 'created_at': '2025-06-06T08:00:00Z' }
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;

      final uid = client.auth.currentUser?.id;
      if (uid == null) {
        throw Exception("User not logged in (auth.currentUser is null).");
      }

      final res = await client
          .from('daily_checkin')
          .select('created_at, payload')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      final list = (res as List).map<Map<String, dynamic>>((row) {
        final map = Map<String, dynamic>.from(row as Map);

        final rawPayload = map['payload'];
        final payload = rawPayload is Map
            ? Map<String, dynamic>.from(rawPayload)
            : <String, dynamic>{};

        return {
          'created_at': map['created_at'],
          'payload': payload,
        };
      }).toList();

      if (!mounted) return;
      setState(() => entries = list);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        entries = [];
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Map<String, int> _countVitaminTypes(List<Map<String, dynamic>> entries) {
    final Map<String, int> counts = {};
    for (final e in entries) {
      final payload = Map<String, dynamic>.from(e['payload'] ?? {});
      final vitamins = Map<String, dynamic>.from(payload['vitamins'] ?? {});
      final type = (vitamins['type'] ?? '').toString().trim();
      if (type.isEmpty) continue;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> countTagsFromEntries(
    List<Map<String, dynamic>> entries,
    List<String> pathKeys, // e.g. ['physical'] or ['sleep','impacts']
  ) {
    final Map<String, int> counts = {};

    for (final e in entries) {
      final payload = Map<String, dynamic>.from(e['payload'] ?? {});
      dynamic current = payload;

      for (final k in pathKeys) {
        if (current is Map && current[k] != null) {
          current = current[k];
        } else {
          current = null;
          break;
        }
      }

      if (current is List) {
        for (final item in current) {
          final key = item.toString().trim();
          if (key.isEmpty) continue;
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  Map<String, int> _countYesNo(List<Map<String, dynamic>> entries) {
    int yes = 0, no = 0;
    for (final e in entries) {
      final payload = Map<String, dynamic>.from(e['payload'] ?? {});
      final vitamins = Map<String, dynamic>.from(payload['vitamins'] ?? {});
      final v = vitamins['took_today'];
      if (v == true) yes++;
      if (v == false) no++;
    }
    return {'Yes': yes, 'No': no};
  }

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

            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "Failed to load summary.\n\n$_error",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : entries.isEmpty
                          ? const Center(
                              child: Text(
                                "No well-being entries yet.",
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 18, 16, 24),
                              itemCount: entries.length + 1, // +1 for chart
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, i) {
                                // Chart at the top
                                if (i == 0) {
                                  final physicalCounts = countTagsFromEntries(
                                      entries, ['physical']);
                                  final emotionCounts = countTagsFromEntries(
                                      entries, ['emotional']);
                                  final sleepImpactCounts =
                                      countTagsFromEntries(
                                          entries, ['sleep', 'impacts']);

                                  final vitaminYesNo =
                                      _countYesNo(entries); // below
                                  final vitaminTypes =
                                      _countVitaminTypes(entries); // below

                                  return Column(
                                    children: [
                                      TopTagsBarChart(
                                          title: "Physical Symptoms (Top)",
                                          counts: physicalCounts),
                                      const SizedBox(height: 14),
                                      TopTagsBarChart(
                                          title: "Emotions (Top)",
                                          counts: emotionCounts),
                                      const SizedBox(height: 14),
                                      TopTagsBarChart(
                                          title: "Sleep Impacts (Top)",
                                          counts: sleepImpactCounts),
                                      const SizedBox(height: 14),
                                      TopTagsBarChart(
                                          title: "Vitamins Type (Top)",
                                          counts: vitaminTypes),
                                      const SizedBox(height: 14),
                                      TopTagsBarChart(
                                          title: "Vitamins Taken (Yes/No)",
                                          counts: vitaminYesNo),
                                      const SizedBox(height: 14),
                                      _WellBeingCharts(entries: entries),
                                    ],
                                  );
                                }

                                final entry = entries[i - 1];
                                final createdAt =
                                    DateTime.tryParse('${entry['created_at']}');

                                final payload = Map<String, dynamic>.from(
                                    entry['payload'] ?? {});

                                final dateStr = _formatDate(createdAt);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _SummaryCard(payload: payload),
                                  ],
                                );
                              },
                            ),
            ),

            // // Continue
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            //   child: SizedBox(
            //     width: double.infinity,
            //     height: 50,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         elevation: 0,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         padding: EdgeInsets.zero,
            //         backgroundColor: const Color.fromARGB(255, 106, 63, 114),
            //       ),
            //       onPressed: () {
            //         Navigator.pushAndRemoveUntil(
            //           context,
            //           MaterialPageRoute(builder: (_) => const HomePage()),
            //           (route) => false,
            //         );
            //       },
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: const [
            //           Text(
            //             'Continue',
            //             style: TextStyle(
            //               fontSize: 20,
            //               fontWeight: FontWeight.w700,
            //               color: Colors.white,
            //             ),
            //           ),
            //           SizedBox(width: 10),
            //           Icon(Icons.arrow_forward_rounded, color: Colors.white),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
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

/// =======================
/// Charts Widget
/// =======================
class _WellBeingCharts extends StatefulWidget {
  final List<Map<String, dynamic>> entries;
  const _WellBeingCharts({required this.entries});

  @override
  State<_WellBeingCharts> createState() => _WellBeingChartsState();
}

class _WellBeingChartsState extends State<_WellBeingCharts> {
  int _tab = 0; // 0 = Sleep hours, 1 = Water ml

  @override
  Widget build(BuildContext context) {
    // Convert entries to points (ascending by time)
    final sleepPoints =
        _buildSeries(widget.entries, metric: _Metric.sleepHours);
    final waterPoints = _buildSeries(widget.entries, metric: _Metric.waterMl);

    final showingSleep = _tab == 0;
    final points = showingSleep ? sleepPoints : waterPoints;

    final title = showingSleep ? 'Sleep Hours (trend)' : 'Water (ml) (trend)';
    final icon =
        showingSleep ? Icons.nights_stay_outlined : Icons.water_drop_outlined;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              _miniTabButton('Sleep',
                  selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _miniTabButton('Water',
                  selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
            ],
          ),
          const SizedBox(height: 12),
          if (points.length < 2)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  "Not enough data for a chart yet.\n(Add 2+ check-ins)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 10,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.round();
                          final dt = points[idx].date.toLocal();
                          final dateLabel = '${dt.day}/${dt.month}/${dt.year}';
                          final valueLabel = spot.y.toStringAsFixed(1);

                          return LineTooltipItem(
                            '$dateLabel\n$valueLabel ${showingSleep ? "hrs" : "ml"}',
                            const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
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
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _bottomInterval(points.length),
                        getTitlesWidget: (value, meta) {
                          // value is x index
                          final idx = value.round();
                          if (idx < 0 || idx >= points.length)
                            return const SizedBox.shrink();
                          final dt = points[idx].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _shortDate(dt),
                              style: const TextStyle(fontSize: 10),
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
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (int i = 0; i < points.length; i++)
                          FlSpot(i.toDouble(), points[i].value),
                      ],
                    ),
                  ],
                  minY: _minY(points),
                  maxY: _maxY(points),
                ),
              ),
            ),
          const SizedBox(height: 10),
          _statsRow(points, showingSleep: showingSleep),
        ],
      ),
    );
  }

  Widget _miniTabButton(String text,
      {required bool selected, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? const Color.fromARGB(255, 106, 63, 114) : Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _statsRow(List<_Point> points, {required bool showingSleep}) {
    if (points.isEmpty) return const SizedBox.shrink();

    final avg =
        points.map((e) => e.value).reduce((a, b) => a + b) / points.length;
    final last = points.last.value;

    final unit = showingSleep ? 'hrs' : 'ml';

    return Row(
      children: [
        Expanded(
          child: _miniStatCard(
            label: 'Average',
            value: '${avg.toStringAsFixed(1)} $unit',
          ),
        ),
        const SizedBox(width: 10),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  int sleepQualityScore(dynamic v) {
    final s = (v ?? '').toString().toLowerCase().trim();
    if (s.contains('poor')) return 1;
    if (s.contains('fair')) return 2;
    if (s.contains('good')) return 3;
    if (s.contains('great') || s.contains('excellent')) return 4;
    return 0; // unknown
  }

  static double _bottomInterval(int n) {
    // Make labels not too crowded
    if (n <= 6) return 1;
    if (n <= 12) return 2;
    if (n <= 20) return 3;
    return 4;
  }

  static String _shortDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month}';
  }

  static double _minY(List<_Point> pts) {
    final minV = pts.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    return (minV - 1).clamp(0, double.infinity);
  }

  static double _maxY(List<_Point> pts) {
    final maxV = pts.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxV + 1;
  }

  /// Builds a time series (ascending). Only takes last 14 valid points.
  static List<_Point> _buildSeries(
    List<Map<String, dynamic>> entries, {
    required _Metric metric,
  }) {
    final List<_Point> out = [];

    for (final e in entries) {
      final createdAt = DateTime.tryParse('${e['created_at']}');
      if (createdAt == null) continue;

      final payload = Map<String, dynamic>.from(e['payload'] ?? {});
      final v = _extractMetric(payload, metric);
      if (v == null) continue;

      out.add(_Point(date: createdAt, value: v));
    }

    // entries is loaded DESC, but chart should be ASC
    out.sort((a, b) => a.date.compareTo(b.date));

    // keep only last 14 points (optional)
    if (out.length > 14) {
      return out.sublist(out.length - 14);
    }
    return out;
  }

  static double? _extractMetric(Map<String, dynamic> payload, _Metric metric) {
    if (metric == _Metric.sleepHours) {
      final sleep = Map<String, dynamic>.from(payload['sleep'] ?? const {});
      final hours = sleep['hours'];
      if (hours == null) return null;

      // supports int/double/"7"
      final numVal =
          (hours is num) ? hours.toDouble() : double.tryParse('$hours');
      return numVal;
    }

    if (metric == _Metric.waterMl) {
      final nutrition =
          Map<String, dynamic>.from(payload['nutrition'] ?? const {});
      final water = nutrition['water_ml'];
      if (water == null) return null;

      final numVal =
          (water is num) ? water.toDouble() : double.tryParse('$water');
      return numVal;
    }

    return null;
  }
}

enum _Metric { sleepHours, waterMl }

class _Point {
  final DateTime date;
  final double value;
  _Point({required this.date, required this.value});
}

/// =======================
/// Existing Summary Card
/// =======================
class _SummaryCard extends StatelessWidget {
  final Map<String, dynamic> payload;
  const _SummaryCard({required this.payload});

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFFEEC5D7);

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
                  'Impacts: ${List<String>.from(sleep['impacts']).join(', ')}',
                ),
              const SizedBox(height: 8),
            ],
            if (nutrition.isNotEmpty) ...[
              const _Label('Nutrition & Hydration'),
              Text('Meals: ${nutrition['meals'] ?? '-'}'),
              Text('Appetite: ${nutrition['appetite'] ?? '-'}'),
              Text(
                'Water: ${nutrition['water_ml'] != null ? '${nutrition['water_ml']} ml' : '-'}',
              ),
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

class TopTagsBarChart extends StatelessWidget {
  final String title;
  final Map<String, int> counts;
  final int topN;

  const TopTagsBarChart({
    super.key,
    required this.title,
    required this.counts,
    this.topN = 6,
  });

  @override
  Widget build(BuildContext context) {
    final items = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = items.take(topN).toList();

    if (top.isEmpty) {
      return _chartCard(title, const Text("No data yet."));
    }

    return _chartCard(
      title,
      SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 10,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final fullLabel = top[group.x.toInt()].key; // ✅ full text
                  final count = rod.toY.toInt();
                  return BarTooltipItem(
                    '$fullLabel\n$count time(s)',
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  );
                },
              ),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
            alignment: BarChartAlignment.spaceAround,
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, meta) => Text(v.toInt().toString(),
                      style: const TextStyle(fontSize: 10)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= top.length)
                      return const SizedBox.shrink();
                    final label = top[i].key;
                    // short label
                    final short = label.length > 10
                        ? '${label.substring(0, 10)}…'
                        : label;

                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(short, style: const TextStyle(fontSize: 10)),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (int i = 0; i < top.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: top[i].value.toDouble(),
                      width: 16,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
