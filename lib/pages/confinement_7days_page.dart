import 'package:ebucare_app/pages/confinement_details_7days_page.dart';
import 'package:flutter/material.dart';

class Confinement7daysPage extends StatefulWidget {
  const Confinement7daysPage({super.key});

  @override
  State<Confinement7daysPage> createState() => _Confinement7daysPageState();
}

class _Confinement7daysPageState extends State<Confinement7daysPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        title: const Text(
          "7 Days Confinement Care",
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 251, 182, 183),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Center(
                          child: Text(
                            "Package Inclusions",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Calsans",
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        _Bullet(
                            "Herbal Bath (Morning & Evening) – 14 sessions"),
                        _Bullet("Massage – 6 sessions"),
                        _Bullet("Hot Stone Therapy – 7 sessions"),
                        _Bullet(
                            "Herbal Body Treatments (Param / Tapel / Pilis) – 14 sessions"),
                        _Bullet("Tummy Binding (Bengkung) – 14 sessions"),
                        _Bullet("Herbal Steam / Sauna – 3 sessions"),
                        _Bullet("Body Scrub – 1 session"),
                        _Bullet(
                            "Baby Care (Bath / Massage / Herbal Compress) – Twice daily"),
                        _Bullet(
                            "Confinement Meals (Morning & Evening) – Ingredients provided by customer"),
                        _Bullet("Laundry for Mother & Baby"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfinementDetails7DaysPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 205, 222, 158),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: "Calsans",
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(" (RM 1,500)",
                            style: TextStyle(color: Colors.white)),
                        Text("BOOK NOW", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, color: Colors.black)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: "Calsans",
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
