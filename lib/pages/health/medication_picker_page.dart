import 'package:flutter/material.dart';

class MedicationPickerPage extends StatefulWidget {
  final String? selected;
  const MedicationPickerPage({super.key, this.selected});

  @override
  State<MedicationPickerPage> createState() => _MedicationPickerPageState();
}

class _MedicationPickerPageState extends State<MedicationPickerPage> {
  final TextEditingController _search = TextEditingController();

  final List<String> _meds = const [
    "Amoxicillin",
    "Benadryl",
    "Calpol",
    "Children's Advil",
    "Children's Tylenol",
    "Claritin Syrup",
    "Fluzone",
    "Gripe water",
    "Motrin",
    "Panadol",
    "Ibuprofen",
    "Cetirizine",
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final filtered = _meds.where((m) => m.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 205, 222, 158),
        title:
            const Text("Medication", style: TextStyle(fontFamily: "Calsans")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.white, fontFamily: "Raleway"),
            decoration: InputDecoration(
              labelText: "Search medication",
              labelStyle: const TextStyle(
                color: Colors.black,
                fontFamily: "Raleway",
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Medications",
            style: TextStyle(color: Colors.black, fontFamily: "Raleway"),
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
          ...filtered.map((name) {
            final isSelected = widget.selected == name;

            return InkWell(
              onTap: () => Navigator.pop(context, name),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
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
