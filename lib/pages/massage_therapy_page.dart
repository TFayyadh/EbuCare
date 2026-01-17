import 'package:ebucare_app/pages/breast_massage_details_page.dart';
import 'package:ebucare_app/pages/fertility_details_page.dart';
import 'package:ebucare_app/pages/pelvic_details_page.dart';
import 'package:ebucare_app/pages/relaxation_details_page.dart';
import 'package:ebucare_app/pages/sciatic_details_page.dart';
import 'package:flutter/material.dart';

class MassageTherapyPage extends StatefulWidget {
  const MassageTherapyPage({super.key});

  @override
  State<MassageTherapyPage> createState() => _MassageTherapyPageState();
}

class _MassageTherapyPageState extends State<MassageTherapyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 226),
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
        backgroundColor: const Color.fromARGB(255, 247, 226, 226),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: const [
              SizedBox(height: 8),
              _TherapyCard(
                title: "🌿 Relaxation Massage",
                desc: "Aroma Massage + Hot Compress (1 Hour 30 Minutes)",
                height: 150,
                onTapPage: RelaxationDetailsPage(),
              ),
              SizedBox(height: 32),
              _TherapyCard(
                title: "🌸 Fertility Care",
                desc:
                    "Aroma Massage + Uterine Massage + Uterine Reposition + Uterine Fumigation + Kegel Exercise (2 Hours)",
                height: 150,
                onTapPage: FertilityDetailsPage(),
              ),
              SizedBox(height: 32),
              _TherapyCard(
                title: "🤱 Pelvic & Core Muscle Recovery",
                desc:
                    "Aroma Massage + Pelvic Restoration + Diastasis Recti Repair + Uterine Reposition + Uterine Fumigation + Belly Wrap (2 Hours)",
                height: 210, // ✅ a bit taller + text is clamped
                onTapPage: PelvicDetailsPage(),
                titleMaxLines: 2,
                descMaxLines: 3,
              ),
              SizedBox(height: 40), // ✅ extra spacing after taller card
              _TherapyCard(
                title: "🔥 Sciatic Nerve Pain Relief",
                desc:
                    "Traditional Massage + Sciatica Nerve Therapy + Soothing Spray Therapy + Hot Compress + Physiotherapy Exercise (2 Hours)",
                height: 170,
                onTapPage: SciaticDetailsPage(),
                titleMaxLines: 2,
                descMaxLines: 3,
              ),
              SizedBox(height: 32),
              _TherapyCard(
                title: "💛 Breast Massage",
                desc:
                    "Breast Massage + Body Massage + Hot Compress (1 Hour 30 Minutes)",
                height: 150,
                onTapPage: BreastMassageDetailsPage(),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TherapyCard extends StatelessWidget {
  final String title;
  final String desc;
  final double height;
  final Widget onTapPage;
  final int titleMaxLines;
  final int descMaxLines;

  const _TherapyCard({
    required this.title,
    required this.desc,
    required this.height,
    required this.onTapPage,
    this.titleMaxLines = 1,
    this.descMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity, // ✅ responsive (no 400 hardcoded)
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 85,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: titleMaxLines, // ✅ prevents overflow
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "Calsans",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          maxLines: descMaxLines, // ✅ prevents overflow
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
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
          Positioned(
            bottom: -18,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => onTapPage),
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
    );
  }
}
