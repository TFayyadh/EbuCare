import 'package:ebucare_app/pages/pelvic_massage_page.dart';
import 'package:flutter/material.dart';

class PelvicDetailsPage extends StatefulWidget {
  const PelvicDetailsPage({super.key});

  @override
  State<PelvicDetailsPage> createState() => _PelvicDetailsPageState();
}

class _PelvicDetailsPageState extends State<PelvicDetailsPage> {
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
                          "Package Details \nPelvic & Core Muscle Recovery",
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
                        "• Aroma Massage + Pelvic Restoration + Diastasis Recti Repair + Uterine Reposition \n+ Uterine Fumigation + Belly Wrap \n (2 hours)\n\n"
                        "Benefits:\n"
                        "• Restores body alignment & waistline shape\n"
                        "• Reduces vaginal looseness & sagging sensation\n"
                        "• Reduces vaginal looseness & sagging sensation\n",
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
                        builder: (context) => PelvicMassagePage()));
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
                    " (RM 279)",
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
