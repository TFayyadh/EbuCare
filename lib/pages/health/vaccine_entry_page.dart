import 'package:flutter/material.dart';
import '../../service/health_supabase_service.dart';
import 'vaccine_picker_page.dart';

class VaccineEntryPage extends StatefulWidget {
  final Map<String, dynamic>? existing; // edit mode
  const VaccineEntryPage({super.key, this.existing});

  @override
  State<VaccineEntryPage> createState() => _VaccineEntryPageState();
}

class _VaccineEntryPageState extends State<VaccineEntryPage> {
  final _svc = HealthSupabaseService();
  final TextEditingController _notesCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  String? _selectedVaccine;

  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      final d = e['entry_date']?.toString(); // YYYY-MM-DD
      if (d != null && d.length >= 10) {
        final y = int.parse(d.substring(0, 4));
        final m = int.parse(d.substring(5, 7));
        final day = int.parse(d.substring(8, 10));
        _date = DateTime(y, m, day);
      }
      final v = (e['vaccine'] ?? '').toString();
      _selectedVaccine = v.isEmpty ? null : v;
      _notesCtrl.text = (e['notes'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String _prettyDate(DateTime dt) => "${dt.day}/${dt.month}/${dt.year}";

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _svc.updateVaccineEntry(
          id: widget.existing!['id'].toString(),
          entryDate: _date,
          vaccine: _selectedVaccine,
          notes: _notesCtrl.text,
          photoUrl: null,
        );
      } else {
        await _svc.addVaccineEntry(
          entryDate: _date,
          vaccine: _selectedVaccine,
          notes: _notesCtrl.text,
          photoUrl: null,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? "Vaccine entry updated ✅" : "Vaccine entry saved ✅",
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
      await _svc.deleteVaccineEntry(widget.existing!['id'].toString());
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
      backgroundColor: const Color(0xFF2D3140), // same as MedicalEntryPage UI
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 205, 222, 158), // same header style
        title: const Text("Vaccine", style: TextStyle(fontFamily: "Calsans")),
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
          // Date row (same style as Medical time row)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Date",
              style: TextStyle(color: Colors.white, fontFamily: "Raleway"),
            ),
            trailing: TextButton(
              onPressed: _saving ? null : _pickDate,
              child: Text(
                _prettyDate(_date),
                style:
                    const TextStyle(color: Colors.white, fontFamily: "Raleway"),
              ),
            ),
          ),
          const Divider(color: Colors.white24),

          // Vaccine picker (styled like a field)
          const Text(
            "Vaccine",
            style: TextStyle(color: Colors.white, fontFamily: "Raleway"),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _saving
                ? null
                : () async {
                    final selected = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VaccinePickerPage(selected: _selectedVaccine),
                      ),
                    );
                    if (selected == null) return;
                    setState(() => _selectedVaccine = selected);
                  },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B3F4E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedVaccine ?? "Tap to choose",
                      style: TextStyle(
                        fontFamily: "Raleway",
                        color: _selectedVaccine == null
                            ? Colors.white54
                            : Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Notes (same as MedicalEntryPage)
          const Text("Notes",
              style: TextStyle(color: Colors.white, fontFamily: "Raleway")),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
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

          // Photo section (same style)
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

          // Save button (same as MedicalEntryPage)
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
}
