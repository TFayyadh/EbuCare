import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GrowthAddRecordPage extends StatefulWidget {
  const GrowthAddRecordPage({super.key});

  @override
  State<GrowthAddRecordPage> createState() => _GrowthAddRecordPageState();
}

class _GrowthAddRecordPageState extends State<GrowthAddRecordPage> {
  final supabase = Supabase.instance.client;

  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _head = TextEditingController();
  final _notes = TextEditingController();

  DateTime _date = DateTime.now();
  bool _saving = false;

  File? _pickedPhoto;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img == null) return;
    setState(() => _pickedPhoto = File(img.path));
  }

  double? _toDouble(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Future<String?> _uploadPhotoIfAny(String userId) async {
    if (_pickedPhoto == null) return null;

    final file = _pickedPhoto!;
    final ext = file.path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = "$userId/growth/$ts.$ext";

    await supabase.storage.from('baby-growth').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return path; // store this in DB (photo_path)
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = supabase.auth.currentUser!;
      final isoDate = DateFormat('yyyy-MM-dd').format(_date);

      // 1) Upload photo to storage (if exists)
      final photoPath = await _uploadPhotoIfAny(user.id);

      // 2) Insert record
      await supabase.from('baby_growth_records').insert({
        'user_id': user.id,
        'recorded_at': isoDate,
        'weight_kg': _toDouble(_weight.text),
        'height_cm': _toDouble(_height.text),
        'head_cm': _toDouble(_head.text),
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        'photo_path': photoPath,
      });

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

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _head.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMMd().format(_date);

    return Scaffold(
      backgroundColor: const Color(0xFF2D3140),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 205, 222, 158),
        title: const Text("Growth", style: TextStyle(fontFamily: "Calsans")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Date",
                style: TextStyle(color: Colors.white, fontFamily: "Raleway")),
            trailing: TextButton(
              onPressed: _pickDate,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: "Raleway")),
            ),
          ),
          const Divider(color: Colors.white24),

          _field("Weight (kg)", _weight),
          _field("Height (cm)", _height),
          _field("Head size (cm)", _head),

          const SizedBox(height: 12),
          const Text("Notes",
              style: TextStyle(color: Colors.white, fontFamily: "Raleway")),
          const SizedBox(height: 6),
          TextField(
            controller: _notes,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontFamily: "Raleway"),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF3B3F4E),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 18),

          // ✅ Add Photo section
          const Text("Photo",
              style: TextStyle(color: Colors.white, fontFamily: "Raleway")),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _pickPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(
                      _pickedPhoto == null ? "Add Photo" : "Change Photo",
                      style: const TextStyle(fontFamily: "Raleway")),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_pickedPhoto != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                _pickedPhoto!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 16),

          // ✅ Save button UNDER Add Photo section
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(fontFamily: "Calsans", fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontFamily: "Raleway"),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF3B3F4E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
