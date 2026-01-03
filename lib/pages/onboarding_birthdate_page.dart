import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class OnboardingBirthdatePage extends StatefulWidget {
  const OnboardingBirthdatePage({super.key});

  @override
  State<OnboardingBirthdatePage> createState() =>
      _OnboardingBirthdatePageState();
}

class _OnboardingBirthdatePageState extends State<OnboardingBirthdatePage> {
  DateTime? _selected;
  bool _saving = false;

  DateTime get _today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime get _minDate => DateTime(_today.year - 5, _today.month, _today.day);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected ?? _today,
      firstDate: _minDate,
      lastDate: _today,
      helpText: "Select baby's birth date",
      confirmText: 'Save',
      cancelText: 'Cancel',
    );
    if (picked != null) setState(() => _selected = picked);
  }

  Future<void> _saveAndContinue() async {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the birth date')));
      return;
    }
    if (_selected!.isAfter(_today) || _selected!.isBefore(_minDate)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select a valid date')));
      return;
    }

    setState(() => _saving = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser!;
      final iso =
          DateFormat('yyyy-MM-dd').format(_selected!); // store as date string

      // Upsert profile row with the birth date (Postgres DATE column recommended)
      await supabase.from('profiles').upsert({
        'id': user.id, // must match your RLS policy
        'baby_birthdate': iso, // e.g., '2025-10-13' or DATE type
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _selected == null
        ? 'Tap to select'
        : DateFormat.yMMMMd().format(_selected!);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.pink.shade50,
                ),
                width: 300,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      "When did you welcome your little one into the world? We’ll use this to support your postpartum journey.",
                      style: TextStyle(
                        fontFamily: "Calsans",
                        fontWeight: FontWeight.w100,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const Text("Welcome 👶",
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Calsans")),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(label,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Raleway"))),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _saveAndContinue,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(
                        "Continue",
                        style: TextStyle(
                            fontFamily: "Calsans",
                            fontWeight: FontWeight.w100,
                            fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
