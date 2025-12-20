import 'package:ebucare_app/pages/breast_massage_details_page.dart';

import 'package:ebucare_app/pages/fertility_details_page.dart';
import 'package:ebucare_app/pages/pelvic_details_page.dart';
import 'package:ebucare_app/pages/relaxation_details_page.dart';
import 'package:ebucare_app/pages/sciatic_details_page.dart';
import 'package:flutter/material.dart';

class MassageTherapyPage extends StatefulWidget {
  const MassageTherapyPage({super.key});

  @override
  State<MassageTherapyPage> createState() => _ConfinementCarePageState();
}

class _ConfinementCarePageState extends State<MassageTherapyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        title: const Text(
          "Massage Therapy",
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Calsans",
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // 👈 make it scrollable
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // ===== CARD 1 =====
// ===== CARD 1 =====
              Container(
                height: 150,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 8,
                        right: 8,
                        bottom: 20,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 👈 center vertically
                        children: [
                          // --- LEFT IMAGE "BADGE" ---
                          SizedBox(
                            width: 85, // fixed width column for image
                            child: Center(
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/baby_blue.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // --- TEXT ---
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "🌿 Relaxation Massage",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Calsans",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Aroma Massage + Hot Compress (1 Hour 30 Minutes)",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Raleway",
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- BUTTON FLOATING AT BOTTOM ---
                    Positioned(
                      bottom: -18,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RelaxationDetailsPage(),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 251, 247, 247),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Book Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Calsans",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              Container(
                height: 150,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 8,
                        right: 8,
                        bottom: 20,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 👈 center vertically
                        children: [
                          // --- LEFT IMAGE "BADGE" ---
                          SizedBox(
                            width: 85, // fixed width column for image
                            child: Center(
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/baby_blue.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // --- TEXT ---
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "🌸 Fertility Care",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Calsans",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Aroma Massage + Uterine Massage + Uterine Reposition + Uterine Fumigation + Kegel Exercise (2 Hours)",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Raleway",
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- BUTTON FLOATING AT BOTTOM ---
                    Positioned(
                      bottom: -18,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FertilityDetailsPage(),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 251, 247, 247),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Book Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Calsans",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),
              Container(
                height: 190,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 8,
                        right: 8,
                        bottom: 20,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 👈 center vertically
                        children: [
                          // --- LEFT IMAGE "BADGE" ---
                          SizedBox(
                            width: 85, // fixed width column for image
                            child: Center(
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/baby_blue.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // --- TEXT ---
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "🤱 Pelvic & Core Muscle Recovery",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Calsans",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Aroma Massage + Pelvic Restoration + Diastasis Recti Repair + Uterine Reposition + Uterine Fumigation + Belly Wrap (2 Hours)",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Raleway",
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- BUTTON FLOATING AT BOTTOM ---
                    Positioned(
                      bottom: -18,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PelvicDetailsPage(),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 251, 247, 247),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Book Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Calsans",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),
              Container(
                height: 170,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 8,
                        right: 8,
                        bottom: 20,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 👈 center vertically
                        children: [
                          // --- LEFT IMAGE "BADGE" ---
                          SizedBox(
                            width: 85, // fixed width column for image
                            child: Center(
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/baby_blue.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // --- TEXT ---
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "🔥 Sciatic Nerve Pain Relief",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Calsans",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Traditional Massage + Sciatica Nerve Therapy + Soothing Spray Therapy + Hot Compress + Physiotherapy Exercise (2 Hours)",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Raleway",
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- BUTTON FLOATING AT BOTTOM ---
                    Positioned(
                      bottom: -18,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SciaticDetailsPage(),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 251, 247, 247),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Book Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Calsans",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),
              Container(
                height: 150,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 182, 183),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 8,
                        right: 8,
                        bottom: 20,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 👈 center vertically
                        children: [
                          // --- LEFT IMAGE "BADGE" ---
                          SizedBox(
                            width: 85, // fixed width column for image
                            child: Center(
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/baby_blue.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // --- TEXT ---
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "💛 Breast Massage",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Calsans",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Breast Massage + Body Massage + Hot Compress (1 Hour 30 Minutes)",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Raleway",
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- BUTTON FLOATING AT BOTTOM ---
                    Positioned(
                      bottom: -18,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BreastMassageDetailsPage(),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 251, 247, 247),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Book Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: "Calsans",
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
