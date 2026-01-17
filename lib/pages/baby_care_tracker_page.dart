import 'package:ebucare_app/pages/baby_feed_page.dart';
import 'package:ebucare_app/pages/baby_sleep_page.dart';
import 'package:ebucare_app/pages/baby_summary_page.dart';
import 'package:flutter/material.dart';

class BabyCareTrackerPage extends StatefulWidget {
  const BabyCareTrackerPage({super.key});

  @override
  State<BabyCareTrackerPage> createState() => _BabyCareTrackerPageState();
}

class _BabyCareTrackerPageState extends State<BabyCareTrackerPage> {
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
                  "Sleep & Feed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Calsans",
                    color: Color.fromARGB(255, 106, 63, 114),
                  ),
                ),
                const SizedBox(height: 12),
                _TrackerCard(
                  title: "Sleep Tracker",
                  imagePath: "assets/images/baby_blue.png",
                  height: 180,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BabySleepPage()),
                    );
                  },
                  fit: BoxFit.fitHeight,
                ),
                const SizedBox(height: 16),
                _TrackerCard(
                  title: "Feed Tracker",
                  imagePath: "assets/images/baby_milks.jpg",
                  height: 180,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BabyFeedPage()),
                    );
                  },
                  fit: BoxFit.fitHeight,
                ),
                const SizedBox(height: 16),
                _TrackerCard(
                  title: "View Summary",
                  imagePath: "assets/images/milk.jpg",
                  height: 160,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BabySummaryPage()),
                    );
                  },
                  fit: BoxFit.fitHeight,
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

class _TrackerCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final double height;
  final VoidCallback onTap;
  final BoxFit fit;

  const _TrackerCard({
    required this.title,
    required this.imagePath,
    required this.height,
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
            textAlign: TextAlign.center,
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
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: fit,
              ),
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromRGBO(210, 145, 188, 1),
            ),
          ),
        ),
      ],
    );
  }
}
