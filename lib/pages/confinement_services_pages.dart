import 'package:ebucare_app/pages/confinement_care_page.dart';
import 'package:ebucare_app/pages/massage_therapy_page.dart';
import 'package:flutter/material.dart';

class ConfinementServicesPages extends StatefulWidget {
  const ConfinementServicesPages({super.key});

  @override
  State<ConfinementServicesPages> createState() =>
      _ConfinementServicesPagesState();
}

class _ConfinementServicesPagesState extends State<ConfinementServicesPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        title: Text(
          "Services",
          style: TextStyle(
            fontFamily: "Calsans",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 247, 226, 226),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfinementCarePage(),
                      ));
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/nanny.png'),
                      fit: BoxFit.fitWidth,
                    ),
                    color: const Color.fromARGB(255, 251, 182, 183),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: Offset(0, 190),
                      child: Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "Confinement Care",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Calsans",
                                color: const Color.fromRGBO(210, 145, 188, 1)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MassageTherapyPage(),
                      ));
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/spa.png'),
                      fit: BoxFit.fitWidth,
                    ),
                    color: const Color.fromRGBO(210, 145, 188, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: Offset(0, 190),
                      child: Container(
                        height: 40,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "Massage Therapy",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Calsans",
                                color: const Color.fromRGBO(210, 145, 188, 1)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
