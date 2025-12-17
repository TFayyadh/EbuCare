import 'package:ebucare_app/pages/checkin_physical_page.dart';
import 'package:ebucare_app/pages/checkin_summary_page.dart';
import 'package:flutter/material.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              "Daily Well-Being",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontFamily: "Calsans",
                color: Color.fromARGB(255, 106, 63, 114),
              ),
            ),
            const SizedBox(height: 120),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // New Well-Being
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckinPhysicalPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        width: 350,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(204, 246, 174, 74),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                      bottom: 0,
                                    ),
                                    child: Text(
                                      "New Well-Being",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w100,
                                        fontFamily: "Calsans",
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                      top: 0,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      "Track your daily well-being here.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Raleway",
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 40,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // View Summary (NO loader, NO button)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckinSummaryPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        width: 350,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(204, 246, 174, 74),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                      top: 8,
                                      bottom: 0,
                                    ),
                                    child: Text(
                                      "View Summary",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w100,
                                        fontFamily: "Calsans",
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                      top: 0,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      "View your previous well-being entries.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Raleway",
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 40,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
