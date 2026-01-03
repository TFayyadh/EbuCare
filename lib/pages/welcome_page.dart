import 'package:ebucare_app/pages/login_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/images/logo2.png'),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  "Hello Mothers,",
                  style: TextStyle(
                      fontSize: 35,
                      fontFamily: "Calsans",
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
                Text(
                  "Welcome to EBUCARE.",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Raleway",
                      color: Colors.white),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ));
              },
              child: Text("GET STARTED",
                  style: TextStyle(
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 106, 63, 114),
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
