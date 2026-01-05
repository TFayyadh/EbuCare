import 'package:ebucare_app/auth/auth_service.dart';
import 'package:ebucare_app/pages/baby_care_page.dart';
import 'package:ebucare_app/pages/checkin_page.dart';
import 'package:ebucare_app/pages/confinement_lady_page.dart';
import 'package:ebucare_app/pages/edu_page.dart';
import 'package:ebucare_app/pages/login_page.dart';
import 'package:ebucare_app/pages/manage_profile.dart';
import 'package:ebucare_app/pages/meditations_page.dart';
import 'package:ebucare_app/pages/reminder_page.dart';
import 'package:ebucare_app/pages/resource_articles.dart';
import 'package:ebucare_app/pages/traditional_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ebucare_app/pages/onboarding_birthdate_page.dart'; // <-- your screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

int _calculatePostpartumWeek(DateTime birthDate) {
  final now = DateTime.now();
  final days = now.isAfter(birthDate) ? now.difference(birthDate).inDays : 0;
  return (days / 7).floor() + 1; // 0–6 days = Week 1, etc.
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
            color: const Color.fromARGB(255, 205, 222, 158),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Daily Reminder",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "Calsans",
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Medication/Hydration/Appointments",
                        style: TextStyle(
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black),
                      )
                    ],
                  ),
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

Widget checkin(context) {
  return Container(
    child: GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckinPage(),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          width: 350,
          height: 100,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 205, 222, 158),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Daily Well-Being",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "Calsans",
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Users daily well-being check-in.",
                        style: TextStyle(
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.health_and_safety_outlined,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ],
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment(0, 0),
                      image: AssetImage("assets/images/logo4.png"),
                      fit: BoxFit.fitHeight),
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
              ),
            ),
            SizedBox(),
          ],
        )),
  );
}

Widget resources(BuildContext context) {
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
                  "Resources",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ],
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment(0, 0),
                      image: AssetImage("assets/images/logo3.png"),
                      fit: BoxFit.fitHeight),
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 230, 186, 192)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResourceArticles(),
                    ),
                  );
                },
                // child: Icon(
                //   Icons.article_outlined,
                //   size: 30,
                //   color: Color.fromARGB(255, 255, 255, 255),
                // ),
              ),
            ),
            SizedBox(),
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
          height: 80,
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
                            left: 8, right: 8, top: 0, bottom: 5),
                        child: Text(
                          "Resources",
                          style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontFamily: "Calsans",
                              fontSize: 22,
                              color: Colors.white),
                        ),
                      ),
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

Widget meditation(BuildContext context) {
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
                  "Meditation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Calsans",
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ],
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                    alignment: Alignment(0, 0),
                    image: AssetImage("assets/images/meditate.png"),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 230, 186, 192),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeditationPage(),
                    ),
                  );
                },
                // child: Icon(
                //   Icons.my_library_music_outlined,
                //   size: 40,
                //   color: Color.fromARGB(255, 255, 255, 255),
                // ),
              ),
            ),
            SizedBox(),
          ],
        )),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ],
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment(0, 0),
                      image: AssetImage("assets/images/baby_growth.png"),
                      fit: BoxFit.cover),
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
              ),
            ),
            SizedBox(),
          ],
        )),
  );
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;

  int? _postpartumWeek;
  bool _loadingProfile = true;

  int _selectedIndex = 0;

  Future<void> logout() async {
    try {
      await authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileAndMaybeRedirect();
  }

  Future<void> _loadProfileAndMaybeRedirect() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        return;
      }

      // Get only what we need
      final data = await supabase
          .from('profiles')
          .select('baby_birthdate')
          .eq('id', uid)
          .single();

      if (data.isEmpty || data['baby_birthdate'] == null) {
        // No birthdate -> onboarding
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingBirthdatePage()),
          );
        }
        return;
      }

      // Supabase returns ISO 8601 strings for date/timestamptz
      final raw = data['baby_birthdate'];
      DateTime? birthDate;

      if (raw is String) {
        birthDate = DateTime.tryParse(raw);
      } else if (raw is int) {
        // if you stored milliseconds since epoch by mistake
        birthDate = DateTime.fromMillisecondsSinceEpoch(raw);
      } else if (raw is DateTime) {
        birthDate = raw;
      }

      if (birthDate == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingBirthdatePage()),
          );
        }
        return;
      }

      final week = _calculatePostpartumWeek(birthDate);

      if (mounted) {
        setState(() {
          _postpartumWeek = week;
          _loadingProfile = false;
        });
      }
    } catch (e) {
      // Fail safe: send to onboarding if we can’t read the field
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingBirthdatePage()),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    //final userEmail = authService.getCurrentUserEmail();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 226),
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
                    if (!_loadingProfile && _postpartumWeek != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "Calsans",
                              color: Color.fromARGB(255, 81, 56, 76),
                            ),
                            children: [
                              const TextSpan(
                                text: "You're currently in ",
                              ),
                              TextSpan(
                                text: "Week ${_postpartumWeek!}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(
                                  text: " of your postpartum recovery."),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      checkin(context),
                      SizedBox(height: 20),
                      reminder(context),
                    ],
                  )),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  child: Container(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        resources(context),
                        meditation(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ManageProfile(initialIndex: index)),
              );
              break;
            case 2:
              // Confirm before logging out
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await logout(); // your existing logout function
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
