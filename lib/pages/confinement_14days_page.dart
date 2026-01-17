import 'package:ebucare_app/pages/confinement_details_14days_page.dart';
import 'package:flutter/material.dart';

class Confinement14daysPage extends StatefulWidget {
  const Confinement14daysPage({super.key});

  @override
  State<Confinement14daysPage> createState() => _Confinement14daysPageState();
}

class _Confinement14daysPageState extends State<Confinement14daysPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        title: const Text(
          "14 Days Confinement Care",
          style: TextStyle(
            fontFamily: "Calsans",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 247, 226, 226),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),

      // ✅ Scrollable + safe padding
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              // ✅ Card auto height (NO height: 550)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Text(
                      "Package Inclusions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Calsans",
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    // ✅ smaller font + better line height = less overflow risk
                    Text(
                      "• Herbal Bath (Morning & Evening) – 28 sessions\n"
                      "• Massage – 12 sessions\n"
                      "• Hot Stone Therapy – 14 sessions\n"
                      "• Herbal Body Treatments (Param / Tapel / Pilis) – 28 sessions\n"
                      "• Tummy Binding (Bengkung) – 28 sessions\n"
                      "• Herbal Steam / Sauna – 7 sessions\n"
                      "• Body Scrub – 1 session\n"
                      "• Baby Care (Bath / Massage / Herbal Compress) – Twice daily\n"
                      "• Confinement Meals (Morning & Evening) – Ingredients provided by customer\n"
                      "• Laundry for Mother & Baby",
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.35,
                        fontFamily: "Calsans",
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Button full width (no max size issues)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConfinementDetails14DaysPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 205, 222, 158),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "(RM 3,150)",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Calsans",
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "BOOK NOW",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Calsans",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
