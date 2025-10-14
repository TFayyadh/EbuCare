import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding_birthdate_page.dart';
import 'home_page.dart';

/// Decides what to show after a user is authenticated:
/// - If profiles.baby_birthdate is NULL/missing → OnboardingBirthdatePage
/// - Else → HomePage
class StartDecider extends StatefulWidget {
  const StartDecider({super.key});

  @override
  State<StartDecider> createState() => _StartDeciderState();
}

class _StartDeciderState extends State<StartDecider> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final supabase = Supabase.instance.client;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        // not logged in → you can route to your login page if needed
        setState(() => _error = 'No session found. Please login again.');
        return;
      }

      // Query the profiles table for this user
      // Assumes profiles.id == auth.users.id and column: baby_birthdate (DATE or TEXT)
      final data = await supabase
          .from('profiles')
          .select('baby_birthdate')
          .eq('id', user.id)
          .maybeSingle(); // returns Map? or null if no row

      final hasDate = data != null &&
          data['baby_birthdate'] != null &&
          '${data['baby_birthdate']}'.isNotEmpty;

      if (!mounted) return;
      if (hasDate) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingBirthdatePage()));
      }
    } catch (e) {
      setState(() => _error = 'Failed to check profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _route, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
