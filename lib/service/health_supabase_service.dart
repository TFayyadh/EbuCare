import 'package:supabase_flutter/supabase_flutter.dart';

class HealthSupabaseService {
  final SupabaseClient _db = Supabase.instance.client;

  String get _uid {
    final uid = _db.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw Exception("User not logged in.");
    }
    return uid;
  }

  // -----------------------
  // MEDICAL
  // -----------------------
  Future<void> addMedicalEntry({
    required DateTime entryTime,
    String? temperature,
    String? medication,
    String? notes,
    String? photoUrl,
  }) async {
    await _db.from('medical_entries').insert({
      'user_id': _uid,
      'entry_time': entryTime.toIso8601String(),
      'temperature': _clean(temperature),
      'medication': _clean(medication),
      'notes': _clean(notes),
      'photo_url': _clean(photoUrl),
    });
  }

  Future<void> updateMedicalEntry({
    required String id,
    required DateTime entryTime,
    String? temperature,
    String? medication,
    String? notes,
    String? photoUrl,
  }) async {
    await _db
        .from('medical_entries')
        .update({
          'entry_time': entryTime.toIso8601String(),
          'temperature': _clean(temperature),
          'medication': _clean(medication),
          'notes': _clean(notes),
          'photo_url': _clean(photoUrl),
        })
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<void> deleteMedicalEntry(String id) async {
    await _db.from('medical_entries').delete().eq('id', id).eq('user_id', _uid);
  }

  Future<List<Map<String, dynamic>>> fetchMedicalEntries() async {
    final data = await _db
        .from('medical_entries')
        .select()
        .eq('user_id', _uid)
        .order('entry_time', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // -----------------------
  // VACCINE
  // -----------------------
  Future<void> addVaccineEntry({
    required DateTime entryDate,
    String? vaccine,
    String? notes,
    String? photoUrl,
  }) async {
    await _db.from('vaccine_entries').insert({
      'user_id': _uid,
      'entry_date': _dateOnly(entryDate),
      'vaccine': _clean(vaccine),
      'notes': _clean(notes),
      'photo_url': _clean(photoUrl),
    });
  }

  Future<void> updateVaccineEntry({
    required String id,
    required DateTime entryDate,
    String? vaccine,
    String? notes,
    String? photoUrl,
  }) async {
    await _db
        .from('vaccine_entries')
        .update({
          'entry_date': _dateOnly(entryDate),
          'vaccine': _clean(vaccine),
          'notes': _clean(notes),
          'photo_url': _clean(photoUrl),
        })
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<void> deleteVaccineEntry(String id) async {
    await _db.from('vaccine_entries').delete().eq('id', id).eq('user_id', _uid);
  }

  Future<List<Map<String, dynamic>>> fetchVaccineEntries() async {
    final data = await _db
        .from('vaccine_entries')
        .select()
        .eq('user_id', _uid)
        .order('entry_date', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<int> countMedicalEntries() async {
    final data =
        await _db.from('medical_entries').select('id').eq('user_id', _uid);

    return (data as List).length;
  }

  Future<int> countVaccineEntries() async {
    final data =
        await _db.from('vaccine_entries').select('id').eq('user_id', _uid);

    return (data as List).length;
  }

  // -----------------------
  // Helpers
  // -----------------------
  String? _clean(String? v) {
    if (v == null) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  String _dateOnly(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
