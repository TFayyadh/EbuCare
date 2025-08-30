import 'package:ebucare_app/auth/auth_service.dart';
import 'package:ebucare_app/pages/baby_care_page.dart';
import 'package:ebucare_app/pages/confinement_lady_page.dart';
import 'package:ebucare_app/pages/edu_page.dart';
import 'package:ebucare_app/pages/login_page.dart';
import 'package:ebucare_app/pages/reminder_page.dart';
import 'package:ebucare_app/pages/resource_articles.dart';
import 'package:ebucare_app/pages/traditional_page.dart';
import 'package:ebucare_app/pages/home/widgets/header.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget edu(BuildContext context) {
  return Container(
    width: 150,
    height: 200,
    decoration: BoxDecoration(
      color: const Color.fromRGBO(210, 145, 188, 1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Educational \nResources",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Calsans",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            Container(
              height: 40,
              width: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(221, 165, 204, 1)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EduPage(),
                    ),
                  );
                },
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 30,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            Text(
              "Insights on \neducational resources.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        )),
  );
}

Widget tips(BuildContext context) {
  return Container(
    width: 150,
    height: 200,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 247, 170, 102),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Traditional \nCare Tips",
                  style: TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                Container(
                  height: 70,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/images/logo4.png'))),
                )
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TraditionalPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Read",
                      style: TextStyle(
                          fontFamily: "Raleway", fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.menu_book_rounded)
                  ],
                )),
            Text(
              "Cultural Practices.",
              style: TextStyle(
                  fontSize: 10,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        )),
  );
}

Widget tips2(BuildContext context) {
  return Container(
    width: 150,
    height: 200,
    decoration: BoxDecoration(
      color: const Color.fromRGBO(210, 145, 188, 1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Traditional \nTips",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Calsans",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            Container(
              height: 40,
              width: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(221, 165, 204, 1)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TraditionalPage(),
                    ),
                  );
                },
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 30,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            Text(
              "Insights on \ntraditional tips.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        )),
  );
}

Widget reminder(context) {
  return Container(
    child: GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReminderPage(),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 8, bottom: 0),
                      child: Text(
                        "Daily Reminder",
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
                        "Medication/Hydration/Appointments",
                        style: TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 12,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.notifications,
                    size: 40,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget confinement(BuildContext context) {
  return Container(
    width: 150,
    height: 200,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 227, 168, 176),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Confinement Lady \nBookings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 230, 186, 192)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfinementLadyPage(),
                    ),
                  );
                },
                child: Icon(
                  Icons.book_rounded,
                  size: 30,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            Text(
              "View or make \nnew bookings.",
              style: TextStyle(
                  fontSize: 10,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        )),
  );
}

Widget article(context) {
  return Container(
    child: GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResourceArticles(),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          width: 350,
          height: 150,
          decoration: BoxDecoration(
            color: const Color.fromARGB(204, 246, 174, 74),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 0, bottom: 15),
                        child: Text(
                          "Resources",
                          style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontFamily: "Calsans",
                              fontSize: 22,
                              color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 0, bottom: 4),
                        child: Text(
                          "Traditional/Modern medical postpartum care resources.",
                          style: TextStyle(
                              fontFamily: "Raleway",
                              fontSize: 15,
                              color: Colors.white),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.article_outlined,
                    size: 45,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget babyCare(BuildContext context) {
  return Container(
    width: 150,
    height: 200,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 227, 168, 176),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Track \nBaby Care",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 230, 186, 192)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BabyCarePage(),
                    ),
                  );
                },
                child: Icon(
                  Icons.baby_changing_station_outlined,
                  size: 30,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            Text(
              "Tracking baby's \ncare.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        )),
  );
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();

  void logout() async {
    try {
      await authService.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //final userEmail = authService.getCurrentUserEmail();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: Header(onLogout: logout),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        "Hello Mother,",
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Calsans",
                            color: const Color.fromARGB(255, 106, 63, 114)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        "Wishing you a smooth postpartum journey.",
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Calsans",
                            fontWeight: FontWeight.w300,
                            color: const Color.fromARGB(255, 81, 56, 76)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: reminder(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        babyCare(context),
                        confinement(context),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: article(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
