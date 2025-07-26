import 'package:ebucare_app/pages/edu_page.dart';
import 'package:ebucare_app/pages/reminder_page.dart';
import 'package:flutter/material.dart';

class ResourceArticles extends StatefulWidget {
  const ResourceArticles({super.key});

  @override
  State<ResourceArticles> createState() => _ResourceArticlesState();
}

class _ResourceArticlesState extends State<ResourceArticles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "Resources",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontFamily: "Calsans",
                color: const Color.fromARGB(255, 106, 63, 114),
              ),
            ),
            SizedBox(
              height: 120,
            ),
            Container(
              height: 300,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EduPage(),
                          ));
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
                              horizontal: 10, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 0, bottom: 0),
                                    child: Text(
                                      "New Reminder",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100,
                                          fontFamily: "Calsans",
                                          fontSize: 18,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 0, bottom: 4),
                                    child: Text(
                                      "Make a new reminder for \nhydration/medication/appointment.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "Raleway",
                                          fontSize: 12,
                                          color: Colors.white),
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
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EduPage(),
                          ));
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
                              horizontal: 10, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 8, bottom: 0),
                                    child: Text(
                                      "View Reminder",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100,
                                          fontFamily: "Calsans",
                                          fontSize: 18,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 0, bottom: 4),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "View your existing reminders for \nhydration/medication/appointment.",
                                      style: TextStyle(
                                          fontFamily: "Raleway",
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  )
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
