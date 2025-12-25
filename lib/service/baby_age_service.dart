import 'package:supabase_flutter/supabase_flutter.dart';

class BabyAge {
  final DateTime birthDate;
  final int ageDays;
  final int ageMonths;

  BabyAge({
    required this.birthDate,
    required this.ageDays,
    required this.ageMonths,
  });
}

class BabyAgeService {
  final SupabaseClient supabase;
  BabyAgeService(this.supabase);

  Future<BabyAge> getBabyAge({DateTime? onDate}) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Not logged in");
    }

    final res = await supabase
        .from('profiles')
        .select('baby_birthdate')
        .eq('id', user.id)
        .single();

    final bd = res['baby_birthdate'];
    if (bd == null || bd.toString().isEmpty) {
      throw Exception("baby_birthdate not found. Please complete onboarding.");
    }

    // Stored as 'yyyy-MM-dd' (or DATE). Parse safely.
    final birthDate = DateTime.parse(bd.toString());
    final ref = onDate ?? DateTime.now();

    final refDate = DateTime(ref.year, ref.month, ref.day);
    final bDate = DateTime(birthDate.year, birthDate.month, birthDate.day);

    final ageDays = refDate.difference(bDate).inDays;

    // Simple month diff (good enough for milestone buckets)
    int months =
        (refDate.year - bDate.year) * 12 + (refDate.month - bDate.month);
    if (refDate.day < bDate.day) {
      months -= 1;
    }
    if (months < 0) months = 0;

    return BabyAge(
      birthDate: bDate,
      ageDays: ageDays < 0 ? 0 : ageDays,
      ageMonths: months,
    );
  }
}
