import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfinementFeedbackPage extends StatefulWidget {
  final int bookingId;
  final String userId;
  final String packageType;

  const ConfinementFeedbackPage({
    super.key,
    required this.bookingId,
    required this.userId,
    required this.packageType,
  });

  @override
  State<ConfinementFeedbackPage> createState() =>
      _ConfinementFeedbackPageState();
}

class _ConfinementFeedbackPageState extends State<ConfinementFeedbackPage> {
  bool _loading = true;
  bool _saving = false;
  bool _alreadySubmitted = false;

  int _rating = 5;
  final _commentCtrl = TextEditingController();

  List<Map<String, String>> _getChecklistItems(String packageTypeRaw) {
    final type = packageTypeRaw.trim().toLowerCase();

    const days7 = <Map<String, String>>[
      {"key": "herbal_bath", "label": "Received 14 sessions of herbal baths."},
      {"key": "massage", "label": "Received 6 sessions of massage."},
      {
        "key": "hot_stone",
        "label": "Received 7 sessions of hot stone therapy."
      },
      {
        "key": "herbal_body",
        "label": "Received 14 sessions of herbal body treatments."
      },
      {
        "key": "tummy_binding",
        "label": "Received 14 sessions of tummy binding."
      },
      {"key": "herbal_steam", "label": "Received 3 sessions of herbal steam."},
      {"key": "body_scrub", "label": "Received 1 session of body scrub."},
      {
        "key": "baby_care",
        "label": "Baby received (bath/massage/herbal compress) twice daily"
      },
      {
        "key": "confinement_meals",
        "label": "Received confinement meals morning & evening."
      },
      {
        "key": "laundry_service",
        "label": "Received laundry service for mother & baby clothes."
      },
    ];

    const days10 = <Map<String, String>>[
      {"key": "herbal_bath", "label": "Received 20 sessions of herbal baths."},
      {"key": "massage", "label": "Received 8 sessions of massage."},
      {
        "key": "hot_stone",
        "label": "Received 8 sessions of hot stone therapy."
      },
      {
        "key": "herbal_body",
        "label": "Received 20 sessions of herbal body treatments."
      },
      {
        "key": "tummy_binding",
        "label": "Received 20 sessions of tummy binding."
      },
      {"key": "herbal_steam", "label": "Received 5 sessions of herbal steam."},
      {"key": "body_scrub", "label": "Received 2 sessions of body scrub."},
      {
        "key": "baby_care",
        "label": "Baby received (bath/massage/herbal compress) twice daily"
      },
      {
        "key": "confinement_meals",
        "label": "Received confinement meals morning & evening."
      },
      {
        "key": "laundry_service",
        "label": "Received laundry service for mother & baby clothes."
      },
    ];

    const days14 = <Map<String, String>>[
      {"key": "herbal_bath", "label": "Received 28 sessions of herbal baths."},
      {"key": "massage", "label": "Received 12 sessions of massage."},
      {
        "key": "hot_stone",
        "label": "Received 14 sessions of hot stone therapy."
      },
      {
        "key": "herbal_body",
        "label": "Received 28 sessions of herbal body treatments."
      },
      {
        "key": "tummy_binding",
        "label": "Received 28 sessions of tummy binding."
      },
      {"key": "herbal_steam", "label": "Received 7 sessions of herbal steam."},
      {"key": "body_scrub", "label": "Received 1 session of body scrub."},
      {
        "key": "baby_care",
        "label": "Baby received (bath/massage/herbal compress) twice daily."
      },
      {
        "key": "confinement_meals",
        "label": "Received confinement meals morning & evening."
      },
      {
        "key": "laundry_service",
        "label": "Received laundry service for mother & baby clothes."
      },
    ];

    const relaxation = <Map<String, String>>[
      {"key": "aroma_massage", "label": "Received Aroma Massage."},
      {"key": "hot_compress", "label": "Received Hot Compress Care."},
      {
        "key": "session_duration",
        "label": "Received 1 hour 30 minutes of session."
      },
    ];

    const fertility = <Map<String, String>>[
      {"key": "aroma_massage", "label": "Received Aroma Massage."},
      {"key": "uterine_massage", "label": "Received Uterine Massage."},
      {
        "key": "uterine_reposition",
        "label": "Received Uterine Reposition Care."
      },
      {
        "key": "uterine_fumigation",
        "label": "Received Uterine Fumigation Care."
      },
      {"key": "kegel_exercise", "label": "Received Kegel Exercise."},
      {"key": "session_duration", "label": "Received 2 hours of session."},
    ];

    const pelvic = <Map<String, String>>[
      {"key": "aroma_massage", "label": "Received Aroma Massage."},
      {
        "key": "pelvic_restoration",
        "label": "Received Pelvic Restoration Care."
      },
      {
        "key": "diastasis_repair",
        "label": "Received Diastasis Recti Repair Care."
      },
      {
        "key": "uterine_reposition",
        "label": "Received Uterine Reposition Care."
      },
      {
        "key": "uterine_fumigation",
        "label": "Received Uterine Fumigation Care."
      },
      {"key": "belly_wrap", "label": "Received Belly Wrap Care."},
      {"key": "session_duration", "label": "Received 2 hours of session."},
    ];

    const sciatic = <Map<String, String>>[
      {"key": "traditional_massage", "label": "Received Traditional Massage."},
      {"key": "sciatic_therapy", "label": "Received Sciatic Nerve Therapy."},
      {"key": "spray_therapy", "label": "Received Soothing Spray Therapy."},
      {"key": "hot_compress", "label": "Received Hot Compress Care."},
      {"key": "physio_exercise", "label": "Received Physiotherapy Exercise."},
      {"key": "session_duration", "label": "Received 2 hours of session."},
    ];

    const breast = <Map<String, String>>[
      {"key": "breast_massage", "label": "Received Breast Massage."},
      {"key": "body_massage", "label": "Received Body Massage."},
      {"key": "hot_compress", "label": "Received Hot Compress Care."},
      {
        "key": "session_duration",
        "label": "Received 1 hour 30 minutes of session."
      },
    ];

    List<Map<String, String>> specific;
    if (type.contains("7 days")) {
      specific = days7;
    } else if (type.contains("10 days")) {
      specific = days10;
    } else if (type.contains("14 days")) {
      specific = days14;
    } else if (type.contains("relaxation")) {
      specific = relaxation;
    } else if (type.contains("fertility")) {
      specific = fertility;
    } else if (type.contains("pelvic")) {
      specific = pelvic;
    } else if (type.contains("sciatic")) {
      specific = sciatic;
    } else if (type.contains("breast")) {
      specific = breast;
    } else {
      specific = days7;
    }

    final seen = <String>{};
    return specific.where((it) => seen.add(it["key"]!)).toList();
  }

  Map<String, bool> _checked = {};

  @override
  void initState() {
    super.initState();
    final items = _getChecklistItems(widget.packageType);
    _checked = {for (final i in items) i["key"]!: false};
    _loadExisting();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);

    final currentItems = _getChecklistItems(widget.packageType);
    for (final it in currentItems) {
      _checked.putIfAbsent(it["key"]!, () => false);
    }

    try {
      final data = await Supabase.instance.client
          .from('confinement_feedback')
          .select()
          .eq('booking_id', widget.bookingId)
          .maybeSingle();

      if (data != null) {
        _alreadySubmitted = true;

        final checklist = (data['checklist'] ?? {}) as Map<String, dynamic>;
        for (final k in _checked.keys) {
          final v = checklist[k];
          if (v is bool) _checked[k] = v;
        }

        final r = data['rating'];
        if (r is int) _rating = r.clamp(1, 5);

        _commentCtrl.text = (data['comment'] ?? '').toString();
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_saving || _alreadySubmitted) return;

    setState(() => _saving = true);
    try {
      final payload = {
        'booking_id': widget.bookingId,
        'user_id': widget.userId,
        'package_type': widget.packageType,
        'checklist': _checked,
        'rating': _rating,
        'comment':
            _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      };

      await Supabase.instance.client
          .from('confinement_feedback')
          .insert(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback submitted ✅")),
      );

      setState(() => _alreadySubmitted = true);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().toLowerCase().contains("duplicate")
          ? "You already submitted feedback for this booking ✅"
          : "Save failed: $e";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

      // If duplicate, lock UI
      if (e.toString().toLowerCase().contains("duplicate")) {
        setState(() => _alreadySubmitted = true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getChecklistItems(widget.packageType);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        title: const Text(
          "Package Feedback",
          style: TextStyle(
            fontFamily: "Calsans",
            color: Color.fromARGB(255, 106, 63, 114),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Package: ${widget.packageType}",
                          style: const TextStyle(
                              fontFamily: "Calsans", fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _alreadySubmitted
                              ? "Status: Submitted ✅"
                              : "Status: Not submitted yet",
                          style: const TextStyle(
                            fontFamily: "Calsans",
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tick what you received",
                          style: TextStyle(fontFamily: "Calsans", fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ...items.map((it) {
                          final key = it["key"]!;
                          final label = it["label"]!;
                          _checked.putIfAbsent(key, () => false);

                          return CheckboxListTile(
                            value: _checked[key] ?? false,
                            onChanged: _alreadySubmitted
                                ? null
                                : (v) => setState(
                                    () => _checked[key] = (v ?? false)),
                            title: Text(label,
                                style: const TextStyle(fontFamily: "Calsans")),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rating: $_rating / 5",
                          style: const TextStyle(
                              fontFamily: "Calsans", fontSize: 16),
                        ),
                        Slider(
                          value: _rating.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: "$_rating",
                          onChanged: _alreadySubmitted
                              ? null
                              : (v) => setState(() => _rating = v.round()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      maxLines: 4,
                      enabled: !_alreadySubmitted,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Comment (optional)",
                        labelStyle: TextStyle(fontFamily: "Calsans"),
                      ),
                      style: const TextStyle(fontFamily: "Calsans"),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          (_saving || _alreadySubmitted) ? null : _submit,
                      child: Text(
                        _saving
                            ? "Saving..."
                            : (_alreadySubmitted
                                ? "Feedback Submitted ✅"
                                : "Submit Feedback"),
                        style: const TextStyle(
                            fontFamily: "Calsans", fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
