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

  Future<void> _save() async {
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
              _isEdit ? "Vaccine entry updated ✅" : "Vaccine entry saved ✅"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2F3D),
        title:
            const Text("Delete entry?", style: TextStyle(color: Colors.white)),
        content: const Text("This cannot be undone.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _svc.deleteVaccineEntry(widget.existing!['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2430),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: "Vaccine",
              leftIcon: Icons.close,
              leftTap: () => Navigator.pop(context),
              rightText: "Save",
              rightTap: _save,
              showDelete: _isEdit,
              onDelete: _delete,
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                children: [
                  _RowItem(
                    label: "Date",
                    value: _prettyDate(_date),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked == null) return;
                      setState(() => _date = picked);
                    },
                  ),
                  _RowItem(
                    label: "Vaccines",
                    value: _selectedVaccine ?? "Add",
                    trailing: Icons.chevron_right,
                    valueColor: _selectedVaccine == null
                        ? const Color(0xFF66C08B)
                        : Colors.white70,
                    onTap: () async {
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
                  ),
                  _RowItem(
                    label: "Notes",
                    value: _notesCtrl.text.isEmpty ? "" : "Added",
                    valueColor: Colors.white70,
                    onTap: () async {
                      final v = await _openTextDialog(
                        title: "Notes",
                        hint: "Write notes...",
                        initial: _notesCtrl.text,
                        maxLines: 6,
                      );
                      if (v == null) return;
                      setState(() => _notesCtrl.text = v);
                    },
                  ),
                  const SizedBox(height: 18),
                  _PhotoButton(
                    text: "Add Photo",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Photo upload next step (Storage).")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _openTextDialog({
    required String title,
    required String hint,
    required String initial,
    int maxLines = 1,
  }) async {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2F3D),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child:
                const Text("Done", style: TextStyle(color: Color(0xFF66C08B))),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final IconData leftIcon;
  final VoidCallback leftTap;
  final String rightText;
  final VoidCallback rightTap;
  final bool showDelete;
  final VoidCallback? onDelete;

  const _TopBar({
    required this.title,
    required this.leftIcon,
    required this.leftTap,
    required this.rightText,
    required this.rightTap,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(color: Color(0xFFB8B6D6)),
      child: Row(
        children: [
          IconButton(
            onPressed: leftTap,
            icon: Icon(leftIcon, color: Colors.black87),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black87,
                  fontFamily: 'Serif',
                ),
              ),
            ),
          ),
          if (showDelete)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.black87),
            ),
          TextButton(
            onPressed: rightTap,
            child: Text(
              rightText,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? trailing;
  final Color? valueColor;

  const _RowItem({
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: valueColor ?? Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailing, color: Colors.white54),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFF2D3446)),
      ],
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PhotoButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 180,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2F3D),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF66C08B), fontSize: 16),
          ),
        ),
      ),
    );
  }
}
