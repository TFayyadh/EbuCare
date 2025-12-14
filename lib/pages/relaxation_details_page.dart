import 'package:ebucare_app/pages/relaxation_massage_page.dart';
import 'package:flutter/material.dart';

class RelaxationDetailsPage extends StatefulWidget {
  const RelaxationDetailsPage({super.key});

  @override
  State<RelaxationDetailsPage> createState() => _RelaxationDetailsPageState();
}

class _RelaxationDetailsPageState extends State<RelaxationDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: Text(
          "Massage Package",
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
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // 👈 This makes height flexible
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Package Details \nRelaxation Massage",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Calsans",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "• Aroma Massage + Hot Compress (1 Hour 30 Minutes)\n"
                        "Benefits:\n"
                        "• Enhances blood circulation\n"
                        "• Reduces muscle pain & stiff nerves\n"
                        "• Promotes deep relaxation\n"
                        "• Improves sleep quality",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Calsans",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RelaxationMassagePage()));
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
                    " (RM 159)",
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
