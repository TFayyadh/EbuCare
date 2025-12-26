import 'package:flutter/material.dart';

class VaccinePickerPage extends StatefulWidget {
  final String? selected;
  const VaccinePickerPage({super.key, this.selected});

  @override
  State<VaccinePickerPage> createState() => _VaccinePickerPageState();
}

class _VaccinePickerPageState extends State<VaccinePickerPage> {
  final TextEditingController _search = TextEditingController();

  final List<Map<String, String>> _vaccines = const [
    {"name": "BCG", "desc": "Bacille Calmette–Guérin (tuberculosis)"},
    {"name": "COVID-19", "desc": ""},
    {
      "name": "DTaP",
      "desc": "Diphtheria, tetanus & whooping cough (pertussis)"
    },
    {"name": "HPV", "desc": "Human papillomavirus"},
    {"name": "HepA", "desc": "Hepatitis A"},
    {"name": "HepB", "desc": "Hepatitis B"},
    {"name": "Hib", "desc": "Haemophilus influenzae type b"},
    {"name": "IIV", "desc": "Flu (influenza)"},
    {"name": "IPV", "desc": "Polio"},
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final filtered = _vaccines.where((v) {
      final n = (v["name"] ?? "").toLowerCase();
      final d = (v["desc"] ?? "").toLowerCase();
      return n.contains(q) || d.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1F2430),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBack(title: "Vaccine", onBack: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2F3D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.add, color: Colors.white70),
                    const SizedBox(width: 8),
                    const Text(
                      "Add Vaccine",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Vaccines",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFF2D3446)),
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  final name = item["name"] ?? "";
                  final desc = item["desc"] ?? "";

                  return ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Serif',
                      ),
                    ),
                    subtitle: desc.isEmpty
                        ? null
                        : Text(desc,
                            style: const TextStyle(color: Colors.white54)),
                    trailing: InkWell(
                      onTap: () => Navigator.pop(context, name),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF66C08B), width: 2),
                        ),
                        child: const Icon(Icons.add, color: Color(0xFF66C08B)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBack extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _HeaderBack({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(color: Color(0xFFB8B6D6)),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
