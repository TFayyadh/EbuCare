import 'package:ebucare_app/pages/baby_care_tracker_page.dart';
import 'package:ebucare_app/pages/baby_growth/baby_growth_home_page.dart';
import 'package:ebucare_app/pages/health/health_page.dart';
import 'package:flutter/material.dart';

class BabyCarePage extends StatefulWidget {
  const BabyCarePage({super.key});

  @override
  State<BabyCarePage> createState() => _BabyCarePageState();
}

class _BabyCarePageState extends State<BabyCarePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 247, 226, 226),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const Text(
                  "Track Baby Care",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Calsans",
                    color: Color.fromARGB(255, 106, 63, 114),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: "Growth & Milestones",
                  imagePath: "assets/images/growth.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BabyGrowthHomePage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: "Sleep & Feed",
                  imagePath: "assets/images/parents.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BabyCareTrackerPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: "Health & Vaccines",
                  imagePath: "assets/images/growth2.png",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HealthPage()),
                    );
                  },
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final BoxFit fit;

  const _SectionCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: "Calsans",
              color: Color.fromRGBO(210, 145, 188, 1),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: fit,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}
