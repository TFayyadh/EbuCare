import 'package:ebucare_app/pages/sciatic_massage_page.dart';
import 'package:flutter/material.dart';

class SciaticDetailsPage extends StatefulWidget {
  const SciaticDetailsPage({super.key});

  @override
  State<SciaticDetailsPage> createState() => _SciaticDetailsPageState();
}

class _SciaticDetailsPageState extends State<SciaticDetailsPage> {
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
                          "Package Details \nSciatic Nerve Pain Relief",
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
                        "• Traditional Massage + Sciatica Nerve Therapy + Soothing Spray Therapy \n+ Hot Compress + Physiotherapy Exercise \n(2 hours)\n\n"
                        "Benefits:\n"
                        "• Relieves radiating sciatic nerve pain\n"
                        "• Loosens piriformis muscle to reduce numbness & tightness\n"
                        "• Improves blood circulation and reduces recurring pain\n",
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
                        builder: (context) => SciaticMassagePage()));
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
                    " (RM 219)",
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
