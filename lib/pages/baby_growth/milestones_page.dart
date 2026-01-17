import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../service/baby_age_service.dart';

class MilestonesPage extends StatefulWidget {
  const MilestonesPage({super.key});

  @override
  State<MilestonesPage> createState() => _MilestonesPageState();
}

class _MilestonesPageState extends State<MilestonesPage> {
  final supabase = Supabase.instance.client;

  bool _saving = false;

  // local selected keys (before save)
  final Set<String> _selectedKeys = {};

  // completion map from supabase: key -> completion data
  final Map<String, Map<String, dynamic>> _doneMap = {};

  // ✅ store draft (date + notes) for selected milestones before Save
  final Map<String, _DraftMilestone> _draftMap = {};

  late final List<_MilestoneGroup> _groups = _buildMilestones();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final user = supabase.auth.currentUser!;
    final rows = await supabase
        .from('baby_milestone_completions')
        .select('milestone_key, achieved_on, notes')
        .eq('user_id', user.id);

    _doneMap.clear();
    for (final r in (rows as List)) {
      final key = r['milestone_key'].toString();
      _doneMap[key] = (r as Map).cast<String, dynamic>();
    }

    if (mounted) setState(() {});
  }

  // ✅ opens dialog for date + notes
  Future<void> _openMilestoneInput(_Milestone m) async {
    final existingDraft = _draftMap[m.key];

    DateTime chosen = existingDraft?.date ??
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final notesController =
        TextEditingController(text: existingDraft?.notes ?? '');

    DateTime tempDate = chosen;

    final result = await showModalBottomSheet<_DraftMilestone>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF3B3F4E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Milestone",
                      style: const TextStyle(
                        fontFamily: "Calsans",
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  )
                ],
              ),
              const SizedBox(height: 6),
              Text(
                m.title,
                style: const TextStyle(
                  fontFamily: "Raleway",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Date row
              const Text(
                "Date achieved",
                style: TextStyle(
                  fontFamily: "Raleway",
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempDate,
                          firstDate: DateTime(DateTime.now().year - 5),
                          lastDate: DateTime.now(),
                          helpText: "Select achieved date",
                        );
                        if (picked != null) {
                          tempDate =
                              DateTime(picked.year, picked.month, picked.day);
                          // rebuild bottom sheet
                          (context as Element).markNeedsBuild();
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text(
                        "${tempDate.year}-${tempDate.month.toString().padLeft(2, '0')}-${tempDate.day.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontFamily: "Raleway"),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Notes
              const Text(
                "Notes (optional)",
                style: TextStyle(
                  fontFamily: "Raleway",
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                style:
                    const TextStyle(color: Colors.white, fontFamily: "Raleway"),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2D3140),
                  hintText: "Add notes...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _DraftMilestone(
                        date: tempDate,
                        notes: notesController.text.trim(),
                      ),
                    );
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(fontFamily: "Calsans"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    // ✅ keep selected + store draft
    setState(() {
      _selectedKeys.add(m.key);
      _draftMap[m.key] = result;
    });
  }

  Future<void> _save() async {
    if (_selectedKeys.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _saving = true);
    try {
      final user = supabase.auth.currentUser!;

      final inserts = <Map<String, dynamic>>[];

      for (final key in _selectedKeys) {
        final m = _findMilestoneByKey(key);
        if (m == null) continue;
        if (_doneMap.containsKey(key)) continue; // already saved

        // ✅ use chosen date + notes if exists; else default to today
        final draft = _draftMap[key];
        final chosenDate = draft?.date ??
            DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day);

        // ✅ compute baby age at chosen date
        final babyAgeAtDate =
            await BabyAgeService(supabase).getBabyAge(onDate: chosenDate);

        final isoDate =
            "${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')}";

        inserts.add({
          'user_id': user.id,
          'milestone_key': m.key,
          'milestone_month': m.month,
          'milestone_title': m.title,
          'achieved_on': isoDate,
          'age_days': babyAgeAtDate.ageDays,
          'age_months': babyAgeAtDate.ageMonths,
          'notes': (draft?.notes.isNotEmpty ?? false) ? draft!.notes : null,
        });
      }

      if (inserts.isNotEmpty) {
        await supabase.from('baby_milestone_completions').insert(inserts);
      }

      await _loadExisting();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to save: $e")));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  _Milestone? _findMilestoneByKey(String key) {
    for (final g in _groups) {
      for (final m in g.items) {
        if (m.key == key) return m;
      }
    }
    return null;
  }

  // ✅ Calculate "Age XmYd" based on birthdate and achieved_on date
  String _ageLabel(DateTime birth, DateTime achieved) {
    final b = DateTime(birth.year, birth.month, birth.day);
    final a = DateTime(achieved.year, achieved.month, achieved.day);

    int months = (a.year - b.year) * 12 + (a.month - b.month);
    if (a.day < b.day) months -= 1;
    if (months < 0) months = 0;

    final shifted = DateTime(b.year, b.month + months, b.day);
    int days = a.difference(shifted).inDays;
    if (days < 0) days = 0;

    return "Age ${months}m${days}d";
  }

  Future<String?> _ageLabelForDone(String key) async {
    final done = _doneMap[key];
    if (done == null) return null;

    final achievedStr = done['achieved_on']?.toString();
    if (achievedStr == null || achievedStr.isEmpty) return null;

    final achievedDate = DateTime.parse(achievedStr);

    final user = supabase.auth.currentUser!;
    final prof = await supabase
        .from('profiles')
        .select('baby_birthdate')
        .eq('id', user.id)
        .single();

    final bd = prof['baby_birthdate'];
    if (bd == null) return null;

    final birthDate = DateTime.parse(bd.toString());
    return _ageLabel(birthDate, achievedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FAE67),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Milestones",
            style: TextStyle(fontFamily: "Calsans", color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Save",
                    style:
                        TextStyle(color: Colors.black, fontFamily: "Raleway")),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, i) {
          final g = _groups[i];
          return _groupTile(g);
        },
      ),
    );
  }

  Widget _groupTile(_MilestoneGroup g) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedIconColor: Colors.black,
        iconColor: Colors.black,
        title: Text(
          "${g.month} months",
          style: const TextStyle(
            color: Colors.black,
            fontFamily: "Raleway",
            fontWeight: FontWeight.w700,
          ),
        ),
        children: g.items.map((m) {
          final done = _doneMap.containsKey(m.key);
          final selected = _selectedKeys.contains(m.key);

          return FutureBuilder<String?>(
            future: done ? _ageLabelForDone(m.key) : Future.value(null),
            builder: (context, snap) {
              final ageText = snap.data;

              return ListTile(
                title: Text(
                  m.title,
                  style: TextStyle(
                    color: done ? Colors.black : Colors.black,
                    fontFamily: "Raleway",
                  ),
                ),
                subtitle: done && ageText != null
                    ? Text(
                        ageText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Raleway",
                          fontSize: 12,
                        ),
                      )
                    : (selected && _draftMap[m.key] != null)
                        ? Text(
                            // show chosen date briefly for selected items (optional)
                            "Selected: ${_draftMap[m.key]!.date.year}-${_draftMap[m.key]!.date.month.toString().padLeft(2, '0')}-${_draftMap[m.key]!.date.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: "Raleway",
                              fontSize: 12,
                            ),
                          )
                        : null,
                trailing: done
                    ? const Icon(Icons.check_circle, color: Color(0xFF2F8E62))
                    : InkWell(
                        onTap: () async {
                          if (selected) {
                            // if already selected, tap again = remove selection
                            setState(() {
                              _selectedKeys.remove(m.key);
                              _draftMap.remove(m.key);
                            });
                            return;
                          }
                          await _openMilestoneInput(m);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2F8E62)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF2F8E62)),
                          ),
                          child: Icon(
                            selected ? Icons.check : Icons.add,
                            color: Colors.black,
                          ),
                        ),
                      ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  List<_MilestoneGroup> _buildMilestones() {
    return [
      _MilestoneGroup(2, [
        _Milestone("2m_calms_when_spoken", 2,
            "Calms down when spoken to or picked up"),
        _Milestone("2m_looks_at_face", 2, "Looks at your face"),
        _Milestone("2m_smiles", 2, "Smiles when you talk or smile at them"),
        _Milestone("2m_reacts_to_sounds", 2, "Reacts to loud sounds"),
        _Milestone("2m_holds_head_tummy", 2, "Holds head up when on tummy"),
        _Milestone("2m_other_sounds", 2, "Makes sounds other than crying"),
        _Milestone("2m_watches_face", 2, "Watches you as you move"),
        _Milestone("2m_moves_both_arms", 2, "Moves both arms and legs"),
        _Milestone("2m_opens_hands", 2, "Opens hands briefly"),
      ]),
      _MilestoneGroup(4, [
        _Milestone("4m_laughs", 4, "Laughs out loud"),
        _Milestone("4m_rolls", 4, "Rolls from tummy to back"),
        _Milestone("4m_reaches_toy", 4, "Reaches for a toy with one hand"),
        _Milestone("4m_chuckles", 4, "Chuckles when playing"),
        _Milestone("4m_sounds_back", 4, "Makes sounds back to you"),
        _Milestone(
            "4m_turns_head", 4, "Turns head towards the sound of your voice"),
        _Milestone("4m_looks_hands", 4, "Looks at own hands with interest"),
        _Milestone("4m_pushes_up", 4, "Pushes up on elbows when on tummy"),
      ]),
      _MilestoneGroup(6, [
        _Milestone("6m_sits_support", 6, "Sits with support"),
        _Milestone("6m_babbles", 6, "Babbles with consonant sounds"),
        _Milestone("6m_passes_objects", 6,
            "Passes objects from one hand to the other"),
        _Milestone("6m_babbles", 6, "Knows familiar faces"),
        _Milestone("6m_looks_mirror", 6, "Likes to look at self in mirror"),
        _Milestone("6m_laughs", 6, "Laughs"),
        _Milestone("6m_closes_lips", 6, "Closes lips to show dislike"),
        _Milestone(
            "6m_pushes_up", 6, "Pushes up with straight arms when on tummy"),
        _Milestone("6m_reaches_toys", 6, "Reaches to grab toys"),
      ]),
      _MilestoneGroup(9, [
        _Milestone("9m_sits_alone", 9, "Sits without support"),
        _Milestone("9m_crawls", 9, "Crawls"),
        _Milestone("9m_responds_name", 9, "Responds to their name"),
        _Milestone(
            "9m_shows_expressions", 9, "Shows several facial expressions"),
        _Milestone(
            "9m_smiles_peekaboo", 9, "Smiles or laughs when you play peekaboo"),
        _Milestone("9m_lifts_arms", 9, "Lifts arms to be picked up"),
        _Milestone("9m_bangs_objects", 9, "Bangs objects together"),
        _Milestone(
            "9m_moves_objects", 9, "Moves objects from one hand to the other"),
      ]),
      _MilestoneGroup(12, [
        _Milestone("12m_stands", 12, "Pulls up to stand"),
        _Milestone("12m_first_words", 12, "Says one or two words"),
        _Milestone("12m_points", 12, "Points to show interest"),
        _Milestone("12m_games", 12, "Plays simple games like pat-a-cake"),
        _Milestone("12m_waves", 12, "Waves goodbye"),
        _Milestone("12m_understands_no", 12, "Understands 'no'"),
        _Milestone(
            "12m_calls_parents", 12, "Calls parent/caregiver 'mama'/'dada'"),
      ]),
      _MilestoneGroup(15, [
        _Milestone("15m_walks", 15, "Walks independently"),
        _Milestone("15m_follows_commands", 15, "Follows simple directions"),
        _Milestone(
            "15m_uses_objects", 15, "Uses objects correctly (cup/brush)"),
        _Milestone("15m_copies_children", 15, "Copies other children"),
        _Milestone("15m_claps_happy", 15, "Claps when happy"),
        _Milestone(
            "15m_shows_affection", 15, "Shows affection to familiar people"),
        _Milestone(
            "15m_points_desire", 15, "Points to ask for something they want"),
      ]),
    ];
  }
}

class _DraftMilestone {
  final DateTime date;
  final String notes;
  _DraftMilestone({required this.date, required this.notes});
}

class _MilestoneGroup {
  final int month;
  final List<_Milestone> items;
  _MilestoneGroup(this.month, this.items);
}

class _Milestone {
  final String key;
  final int month;
  final String title;
  _Milestone(this.key, this.month, this.title);
}
