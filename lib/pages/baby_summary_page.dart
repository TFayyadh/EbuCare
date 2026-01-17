import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class BabySummaryPage extends StatefulWidget {
  const BabySummaryPage({super.key});

  @override
  State<BabySummaryPage> createState() => _BabySummaryPageState();
}

class _BabySummaryPageState extends State<BabySummaryPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> feedEntries = [];
  List<Map<String, dynamic>> sleepEntries = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
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

      // ---- FEED ----
      final feedRes = await client
          .from('baby_feed')
          .select()
          .eq('user_id', uid)
          .order('date', ascending: false);

      // ---- SLEEP ----
      final sleepRes = await client
          .from('baby_sleep')
          .select()
          .eq('user_id', uid)
          .order('date', ascending: false);

      feedEntries =
          (feedRes as List).map((e) => Map<String, dynamic>.from(e)).toList();
      sleepEntries =
          (sleepRes as List).map((e) => Map<String, dynamic>.from(e)).toList();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        feedEntries = [];
        sleepEntries = [];
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // =========================
  // Helpers: parsing
  // =========================

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  /// Supports "10:05 PM", "10:05 AM", also "22:05"
  TimeOfDay? _parseTimeOfDay(String? s) {
    if (s == null) return null;
    final raw = s.trim();
    if (raw.isEmpty) return null;

    // 24h format: "22:05"
    final m24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (m24 != null) {
      final h = int.parse(m24.group(1)!);
      final min = int.parse(m24.group(2)!);
      if (h >= 0 && h <= 23 && min >= 0 && min <= 59) {
        return TimeOfDay(hour: h, minute: min);
      }
    }

    // 12h format: "10:05 PM"
    final m12 = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(raw);
    if (m12 != null) {
      int h = int.parse(m12.group(1)!);
      final min = int.parse(m12.group(2)!);
      final ap = m12.group(3)!.toUpperCase();

      if (h == 12) h = 0; // 12AM -> 0
      if (ap == 'PM') h += 12;

      if (h >= 0 && h <= 23 && min >= 0 && min <= 59) {
        return TimeOfDay(hour: h, minute: min);
      }
    }

    return null;
  }

  double? _sleepHoursFromEntry(Map<String, dynamic> row) {
    final st = _parseTimeOfDay(row['start_time']?.toString());
    final et = _parseTimeOfDay(row['end_time']?.toString());
    final date = _parseDate(row['date']);
    if (st == null || et == null || date == null) return null;

    final start = DateTime(date.year, date.month, date.day, st.hour, st.minute);
    var end = DateTime(date.year, date.month, date.day, et.hour, et.minute);

    // if end earlier than start, assume it ends next day
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final mins = end.difference(start).inMinutes;
    if (mins <= 0) return null;
    return mins / 60.0;
  }

  int? _minutesFromDurationString(String? s) {
    if (s == null) return null;
    final t = s.trim().toLowerCase();
    if (t.isEmpty) return null;
    if (t.contains('>')) return 65; // >60 minutes => treat as 65
    final m = RegExp(r'(\d+)').firstMatch(t);
    if (m == null) return null;
    return int.tryParse(m.group(1)!);
  }

  double? _mlFromAmountString(String? s) {
    if (s == null) return null;
    final t = s.trim().toLowerCase();
    if (t.isEmpty) return null;

    // handles "<50 ml" => 50, "> 500 ml" => 520
    if (t.contains('<')) {
      final m = RegExp(r'(\d+)').firstMatch(t);
      if (m == null) return null;
      return (double.tryParse(m.group(1)!) ?? 0);
    }
    if (t.contains('>')) {
      final m = RegExp(r'(\d+)').firstMatch(t);
      if (m == null) return null;
      final base = (double.tryParse(m.group(1)!) ?? 0);
      return base + 20; // slight bump
    }

    final m = RegExp(r'(\d+)').firstMatch(t);
    if (m == null) return null;
    return double.tryParse(m.group(1)!);
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }

  // =========================
  // Aggregations (Bar charts)
  // =========================

  Map<String, int> _countByKey(List<Map<String, dynamic>> rows, String key) {
    final Map<String, int> out = {};
    for (final r in rows) {
      final v = (r[key] ?? '').toString().trim();
      if (v.isEmpty) continue;
      out[v] = (out[v] ?? 0) + 1;
    }
    return out;
  }

  Map<String, int> _countBreastSide(List<Map<String, dynamic>> rows) {
    final bm = rows
        .where((e) => (e['feeding_type'] ?? '').toString() == 'Breast Milk')
        .toList();
    return _countByKey(bm, 'breast_side');
  }

  Map<String, int> _countFormulaAmountBuckets(List<Map<String, dynamic>> rows) {
    final fm = rows
        .where((e) => (e['feeding_type'] ?? '').toString() == 'Formula Milk')
        .toList();

    final Map<String, int> out = {};
    for (final r in fm) {
      final amt = (r['amount'] ?? '').toString().trim();
      if (amt.isEmpty) continue;
      out[amt] = (out[amt] ?? 0) + 1;
    }
    return out;
  }

  Map<String, int> _countBreastDurationBuckets(
      List<Map<String, dynamic>> rows) {
    final bm = rows
        .where((e) => (e['feeding_type'] ?? '').toString() == 'Breast Milk')
        .toList();

    final Map<String, int> out = {};
    for (final r in bm) {
      final dur = (r['duration'] ?? '').toString().trim();
      if (dur.isEmpty) continue;
      out[dur] = (out[dur] ?? 0) + 1;
    }
    return out;
  }

  // =========================
  // Trend series (Line charts)
  // =========================

  List<_Point> _sleepTrend() {
    final List<_Point> pts = [];
    for (final r in sleepEntries) {
      final dt = _parseDate(r['date']);
      final hrs = _sleepHoursFromEntry(r);
      if (dt == null || hrs == null) continue;
      pts.add(_Point(date: dt, value: hrs));
    }
    pts.sort((a, b) => a.date.compareTo(b.date));
    if (pts.length > 14) return pts.sublist(pts.length - 14);
    return pts;
  }

  List<_Point> _feedCountTrend() {
    // group by date (day) => count entries
    final Map<String, int> byDay = {};
    for (final r in feedEntries) {
      final dt = _parseDate(r['date']);
      if (dt == null) continue;
      final key = '${dt.year}-${dt.month}-${dt.day}';
      byDay[key] = (byDay[key] ?? 0) + 1;
    }

    final keys = byDay.keys.toList()
      ..sort((a, b) => _dayKeyToDate(a).compareTo(_dayKeyToDate(b)));

    final pts = <_Point>[];
    for (final k in keys) {
      pts.add(
          _Point(date: _dayKeyToDate(k), value: (byDay[k] ?? 0).toDouble()));
    }
    if (pts.length > 14) return pts.sublist(pts.length - 14);
    return pts;
  }

  DateTime _dayKeyToDate(String key) {
    final parts = key.split('-');
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);
    return DateTime(y, m, d);
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    const pinkBg = Color(0xFFFFE6EC);

    final feedingTypeCounts = _countByKey(feedEntries, 'feeding_type');
    final breastSideCounts = _countBreastSide(feedEntries);
    final breastDurationCounts = _countBreastDurationBuckets(feedEntries);
    final formulaAmountCounts = _countFormulaAmountBuckets(feedEntries);
    final sleepQualityCounts = _countByKey(sleepEntries, 'sleep_quality');

    final sleepTrend = _sleepTrend();
    final feedTrend = _feedCountTrend();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (same vibe as your CheckinSummaryPage)
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
                      'BABY SUMMARY',
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
                    child: Icon(Icons.child_care_outlined, size: 48),
                  )
                ],
              ),
            ),

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
                      : (feedEntries.isEmpty && sleepEntries.isEmpty)
                          ? const Center(
                              child: Text(
                                "No baby feed/sleep entries yet.",
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 18, 16, 24),
                              children: [
                                TopTagsBarChart(
                                  title: "Feeding Type (Top)",
                                  counts: feedingTypeCounts,
                                ),
                                const SizedBox(height: 14),
                                TopTagsBarChart(
                                  title: "Breast Side (Top)",
                                  counts: breastSideCounts,
                                ),
                                const SizedBox(height: 14),
                                TopTagsBarChart(
                                  title: "Breastfeeding Duration (Top)",
                                  counts: breastDurationCounts,
                                ),
                                const SizedBox(height: 14),
                                TopTagsBarChart(
                                  title: "Formula Amount (Top)",
                                  counts: formulaAmountCounts,
                                ),
                                const SizedBox(height: 14),
                                TopTagsBarChart(
                                  title: "Sleep Quality (Top)",
                                  counts: sleepQualityCounts,
                                ),
                                const SizedBox(height: 14),
                                _TrendCard(
                                  title: "Sleep Hours (trend)",
                                  unit: "hrs",
                                  icon: Icons.nights_stay_outlined,
                                  points: sleepTrend,
                                ),
                                const SizedBox(height: 14),
                                _TrendCard(
                                  title: "Feeds per Day (trend)",
                                  unit: "feeds",
                                  icon: Icons.restaurant_outlined,
                                  points: feedTrend,
                                  integerY: true,
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  "Recent Entries",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ..._buildRecentCards(),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentCards() {
    // merge both lists into one timeline-ish list (show last 12)
    final merged = <Map<String, dynamic>>[];

    for (final f in feedEntries) {
      merged.add({
        '_type': 'feed',
        '_date': _parseDate(f['date']),
        ...f,
      });
    }
    for (final s in sleepEntries) {
      merged.add({
        '_type': 'sleep',
        '_date': _parseDate(s['date']),
        ...s,
      });
    }

    merged.sort((a, b) {
      final da =
          (a['_date'] as DateTime?) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db =
          (b['_date'] as DateTime?) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da); // desc
    });

    final take = merged.take(12).toList();

    return take.map((e) {
      final type = (e['_type'] ?? '').toString();
      final dt = e['_date'] as DateTime?;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _EntryCard(
          title: type == 'feed' ? 'Feed' : 'Sleep',
          dateLabel: _formatDate(dt),
          body: type == 'feed' ? _feedCardBody(e) : _sleepCardBody(e),
        ),
      );
    }).toList();
  }

  Widget _feedCardBody(Map<String, dynamic> e) {
    final ft = (e['feeding_type'] ?? '-').toString();
    final time = (e['time'] ?? '-').toString();
    final notes = (e['notes'] ?? '').toString().trim();
    final desc = (e['food_description'] ?? '').toString().trim();

    final breastSide = (e['breast_side'] ?? '').toString().trim();
    final dur = (e['duration'] ?? '').toString().trim();
    final amt = (e['amount'] ?? '').toString().trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time: $time'),
        Text('Type: $ft'),
        if (ft == 'Breast Milk') ...[
          if (breastSide.isNotEmpty) Text('Side: $breastSide'),
          if (dur.isNotEmpty) Text('Duration: $dur'),
        ],
        if (ft == 'Formula Milk') ...[
          if (amt.isNotEmpty) Text('Amount: $amt'),
        ],
        if (ft == 'Solid Food') ...[
          if (desc.isNotEmpty) Text('Food: $desc'),
        ],
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Notes: $notes'),
        ],
      ],
    );
  }

  Widget _sleepCardBody(Map<String, dynamic> e) {
    final st = (e['start_time'] ?? '-').toString();
    final et = (e['end_time'] ?? '-').toString();
    final q = (e['sleep_quality'] ?? '-').toString();
    final notes = (e['notes'] ?? '').toString().trim();

    final hrs = _sleepHoursFromEntry(e);
    final hrsText = hrs == null ? '-' : hrs.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Start: $st'),
        Text('End: $et'),
        Text('Hours: $hrsText'),
        Text('Quality: $q'),
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Notes: $notes'),
        ],
      ],
    );
  }
}

/// =======================
/// Reusable Entry Card
/// =======================
class _EntryCard extends StatelessWidget {
  final String title;
  final String dateLabel;
  final Widget body;

  const _EntryCard({
    required this.title,
    required this.dateLabel,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFFEEC5D7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 13.5, color: Colors.black),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title • $dateLabel",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            body,
          ],
        ),
      ),
    );
  }
}

/// =======================
/// Trend Line Card
/// =======================
class _TrendCard extends StatelessWidget {
  final String title;
  final String unit;
  final IconData icon;
  final List<_Point> points;
  final bool integerY;

  const _TrendCard({
    required this.title,
    required this.unit,
    required this.icon,
    required this.points,
    this.integerY = false,
  });

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
          const SizedBox(height: 12),
          if (points.length < 2)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  "Not enough data for a chart yet.\n(Add 2+ entries)",
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
                        return touchedSpots
                            .map((spot) {
                              final idx = spot.x.round();
                              if (idx < 0 || idx >= points.length) {
                                return null;
                              }
                              final dt = points[idx].date.toLocal();
                              final dateLabel =
                                  '${dt.day}/${dt.month}/${dt.year}';
                              final val = integerY
                                  ? spot.y.toStringAsFixed(0)
                                  : spot.y.toStringAsFixed(1);

                              return LineTooltipItem(
                                '$dateLabel\n$val $unit',
                                const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              );
                            })
                            .whereType<LineTooltipItem>()
                            .toList();
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
                          final t = integerY
                              ? value.toInt().toString()
                              : value.toStringAsFixed(0);
                          return Text(t, style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _bottomInterval(points.length),
                        getTitlesWidget: (value, meta) {
                          final idx = value.round();
                          if (idx < 0 || idx >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final dt = points[idx].date.toLocal();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${dt.day}/${dt.month}',
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
          _statsRow(points),
        ],
      ),
    );
  }

  Widget _statsRow(List<_Point> points) {
    if (points.isEmpty) return const SizedBox.shrink();
    final avg =
        points.map((e) => e.value).reduce((a, b) => a + b) / points.length;
    final last = points.last.value;

    final avgText = integerY ? avg.toStringAsFixed(0) : avg.toStringAsFixed(1);
    final lastText =
        integerY ? last.toStringAsFixed(0) : last.toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: _miniStatCard(
            label: 'Average',
            value: '$avgText $unit',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniStatCard(
            label: 'Latest',
            value: '$lastText $unit',
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

  static double _bottomInterval(int n) {
    if (n <= 6) return 1;
    if (n <= 12) return 2;
    if (n <= 20) return 3;
    return 4;
  }

  static double _minY(List<_Point> pts) {
    final minV = pts.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    return (minV - 1).clamp(0, double.infinity);
  }

  static double _maxY(List<_Point> pts) {
    final maxV = pts.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxV + 1;
  }
}

class _Point {
  final DateTime date;
  final double value;
  _Point({required this.date, required this.value});
}

/// =======================
/// Bar Chart (same style as your CheckinSummaryPage)
/// =======================
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
                  final fullLabel = top[group.x.toInt()].key;
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
                    if (i < 0 || i >= top.length) {
                      return const SizedBox.shrink();
                    }
                    final label = top[i].key;
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
