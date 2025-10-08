import 'package:ebucare_app/pages/confinement_details_10days_page.dart';
import 'package:flutter/material.dart';

class Confinement10daysPage extends StatefulWidget {
  const Confinement10daysPage({super.key});

  @override
  State<Confinement10daysPage> createState() => _Confinement10daysPageState();
}

class _Confinement10daysPageState extends State<Confinement10daysPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: Text(
          "10 Days Confinement Care",
          style: TextStyle(
            fontFamily: "Calsans",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                width: double.infinity,
                height: 550,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15),
                    child: Column(
                      children: [
                        Text(
                          "Package Inclusions",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Calsans",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "• Herbal Bath (Morning & Evening) – 20 sessions \n• Massage – 8 sessions \n• Hot Stone Therapy – 8 sessions \n• Herbal Body Treatments \n(Param / Tapel / Pilis) – 20 sessions \n• Tummy Binding (Bengkung) – 20 sessions \n• Herbal Steam / Sauna – 5 sessions \n• Body Scrub – 2 sessions \n• Baby Care (Bath / Massage / \nHerbal Compress) – Twice daily \n• Confinement Meals (Morning & Evening) – Ingredients provided by customer \n• Laundry for Mother & Baby",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Calsans",
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfinementDetails10DaysPage()));
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(Color.fromARGB(255, 174, 121, 183)),
                maximumSize: WidgetStatePropertyAll(Size(350, 50)),
                padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 16, fontFamily: "Calsans")),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "(RM2,250)",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "BOOK NOW",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
