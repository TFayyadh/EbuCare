import 'package:flutter/material.dart';
import '../../service/health_supabase_service.dart';
import 'medication_picker_page.dart';

class MedicalEntryPage extends StatefulWidget {
  final Map<String, dynamic>? existing; // if not null => edit mode
  const MedicalEntryPage({super.key, this.existing});

  @override
  State<MedicalEntryPage> createState() => _MedicalEntryPageState();
}

class _MedicalEntryPageState extends State<MedicalEntryPage> {
  final _svc = HealthSupabaseService();

  final TextEditingController _tempCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  DateTime _time = DateTime.now();
  String? _selectedMedication;

  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      final t = e['entry_time']?.toString();
      if (t != null) _time = DateTime.parse(t).toLocal();

      _tempCtrl.text = (e['temperature'] ?? '').toString();
      _notesCtrl.text = (e['notes'] ?? '').toString();
      final med = (e['medication'] ?? '').toString();
      _selectedMedication = med.isEmpty ? null : med;
    }
  }

  @override
  void dispose() {
    _tempCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? "pm" : "am";
    return "Today  $hour:$min$ampm";
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (picked == null) return;
    setState(() {
      _time = DateTime(
        _time.year,
        _time.month,
        _time.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _svc.updateMedicalEntry(
          id: widget.existing!['id'].toString(),
          entryTime: _time,
          temperature: _tempCtrl.text,
          medication: _selectedMedication,
          notes: _notesCtrl.text,
          photoUrl: null,
        );
      } else {
        await _svc.addMedicalEntry(
          entryTime: _time,
          temperature: _tempCtrl.text,
          medication: _selectedMedication,
          notes: _notesCtrl.text,
          photoUrl: null,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? "Medical entry updated ✅" : "Medical entry saved ✅",
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2F3D),
        title: const Text("Delete entry?",
            style: TextStyle(color: Colors.white, fontFamily: "Raleway")),
        content: const Text(
          "This cannot be undone.",
          style: TextStyle(color: Colors.white70, fontFamily: "Raleway"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.white70, fontFamily: "Raleway")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete",
                style:
                    TextStyle(color: Colors.redAccent, fontFamily: "Raleway")),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _svc.deleteMedicalEntry(widget.existing!['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Deleted ✅")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 247, 226, 226), // same as GrowthAddRecordPage
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 205, 222, 158), // same style as Growth header
        title: const Text("Medical", style: TextStyle(fontFamily: "Calsans")),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time (like Date row in growth)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Time",
              style: TextStyle(color: Colors.black, fontFamily: "Raleway"),
            ),
            trailing: TextButton(
              onPressed: _saving ? null : _pickTime,
              child: Text(
                _formatTime(_time),
                style:
                    const TextStyle(color: Colors.black, fontFamily: "Raleway"),
              ),
            ),
          ),
          const Divider(color: Colors.white24),

          // Temperature input (direct TextField like Growth page)
          _field("Temperature (e.g. 37.5°C)", _tempCtrl,
              keyboardType: TextInputType.text),

          const SizedBox(height: 8),

          // Medication picker (styled like a field)
          const Text(
            "Medication",
            style: TextStyle(color: Colors.black, fontFamily: "Raleway"),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _saving
                ? null
                : () async {
                    final selected = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicationPickerPage(
                          selected: _selectedMedication,
                        ),
                      ),
                    );
                    if (selected == null) return;
                    setState(() => _selectedMedication = selected);
                  },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedMedication ?? "Tap to choose",
                      style: TextStyle(
                        fontFamily: "Raleway",
                        color: _selectedMedication == null
                            ? Colors.black
                            : Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Notes
          const Text("Notes",
              style: TextStyle(color: Colors.black, fontFamily: "Raleway")),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.black, fontFamily: "Raleway"),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 18),

          // Photo button (same placement/style like Growth, but logic not added yet)
          const Text("Photo",
              style: TextStyle(color: Colors.white, fontFamily: "Raleway")),
          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: _saving
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Photo upload next step (Storage)."),
                      ),
                    );
                  },
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text("Add Photo",
                style: TextStyle(fontFamily: "Raleway")),
          ),

          const SizedBox(height: 16),

          // Save button (same as Growth)
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
                  : Text(
                      _isEdit ? "Update" : "Save",
                      style:
                          const TextStyle(fontFamily: "Calsans", fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black, fontFamily: "Raleway"),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.black, fontFamily: "Raleway"),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
