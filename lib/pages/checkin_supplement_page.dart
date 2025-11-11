import 'package:ebucare_app/pages/checkin_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckinSupplementPage extends StatefulWidget {
  final Map<String, dynamic> collected; // everything so far
  const CheckinSupplementPage({super.key, required this.collected});

  @override
  State<CheckinSupplementPage> createState() => _CheckinSupplementPageState();
}

class _CheckinSupplementPageState extends State<CheckinSupplementPage> {
  bool? _tookSupplements; // true = YES, false = NO
  final TextEditingController _typeCtrl = TextEditingController();
  bool _saving = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _typeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pinkBg = Color(0xFFFFE6EC);
    const green = Color(0xFF7AD68A);

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
                children: [
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'VITAMINS &\nSUPPLEMENTS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 6, top: 2),
                    child: Icon(Icons.self_improvement_outlined, size: 48),
                  )
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Did you take your postpartum supplement today?',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        _yesNoChip(
                          label: 'YES',
                          selected: _tookSupplements == true,
                          color: green,
                          onTap: () => setState(() {
                            _tookSupplements = true;
                          }),
                        ),
                        _yesNoChip(
                          label: 'NO',
                          selected: _tookSupplements == false,
                          color: const Color(0xFFF08A8A),
                          onTap: () => setState(() {
                            _tookSupplements = false;
                            _typeCtrl.clear();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'What type of supplement did you take?',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _typeCtrl,
                      enabled: _tookSupplements == true, // only enable when YES
                      decoration: InputDecoration(
                        hintText: 'Type here',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Continue (Save + go to Summary)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: _saving ? null : _saveAndGoToSummary,
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF7ECF),
                          Color(0xFFF76BB6),
                          Color(0xFFEE62AE)
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_saving)
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        else
                          const Text(
                            'Continue',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yesNoChip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFFAF1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? color : const Color(0xFFDADADA), width: 1.6),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(label, style: const TextStyle(fontSize: 13.5)),
      ),
    );
  }

  Future<void> _saveAndGoToSummary() async {
    setState(() => _saving = true);

    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('No logged-in user.');
      }

      // Build final payload (EVERYTHING)
      final data = {
        ...widget.collected,
        'vitamins': {
          'took_today': _tookSupplements, // true | false | null
          'type': _tookSupplements == true
              ? (_typeCtrl.text.trim().isEmpty ? null : _typeCtrl.text.trim())
              : null,
        },
      };

      // Insert into Supabase
      await supabase.from('daily_checkin').insert({
        'user_id': currentUserId,
        'payload': data,
      });

      // Fetch recent (latest 7) to show on Summary
      final rows = await supabase
          .from('daily_checkin')
          .select('payload, created_at')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(7);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckinSummaryPage(
              entries: List<Map<String, dynamic>>.from(rows)),
        ),
      );

      if (mounted)
        Navigator.pop(context, data); // bubble back to page 1 if needed
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
