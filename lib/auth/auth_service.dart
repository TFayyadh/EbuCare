import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final supabase = Supabase.instance.client;

    // 1. Sign up the user
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
      },
    );

    final user = authResponse.user;
    if (user != null) {
      final userId = user.id;

      final existingProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (existingProfile == null) {
        // Insert only if not exists
        await supabase.from('profiles').insert({
          'id': userId,
          'name': name,
        });
      }
    }
  }

  //Sign in with Email & Password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  //Sign up with Email & Password
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  //Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //Get User Email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<List<dynamic>> fetchResources() async {
    final data = await Supabase.instance.client
        .from('resources') // e.g., 'resources'
        .select()
        .eq('resource_type', 'Educational');
    print(data);

    return data;
  }
}
