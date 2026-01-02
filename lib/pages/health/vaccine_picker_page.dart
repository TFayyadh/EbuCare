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
      backgroundColor: const Color(0xFF2D3140),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7FAE67),
        title: const Text("Vaccine", style: TextStyle(fontFamily: "Calsans")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search box (same style like your fields)
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white, fontFamily: "Raleway"),
            decoration: InputDecoration(
              labelText: "Search vaccine",
              labelStyle: const TextStyle(
                color: Colors.white70,
                fontFamily: "Raleway",
              ),
              filled: true,
              fillColor: const Color(0xFF3B3F4E),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "Vaccines",
            style: TextStyle(color: Colors.white54, fontFamily: "Raleway"),
          ),
          const SizedBox(height: 10),

          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(
                child: Text(
                  "No results",
                  style:
                      TextStyle(color: Colors.white70, fontFamily: "Raleway"),
                ),
              ),
            ),

          ...filtered.map((item) {
            final name = item["name"] ?? "";
            final desc = item["desc"] ?? "";
            final isSelected = widget.selected == name;

            return InkWell(
              onTap: () => Navigator.pop(context, name),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B3F4E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Raleway",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              desc,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontFamily: "Raleway",
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF66C08B),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.add,
                        color:
                            isSelected ? Colors.white : const Color(0xFF66C08B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
