import 'package:ebucare_app/pages/confinement_10days_page.dart';
import 'package:ebucare_app/pages/confinement_14days_page.dart';
import 'package:ebucare_app/pages/confinement_7days_page.dart';
import 'package:flutter/material.dart';

class ConfinementCarePage extends StatefulWidget {
  const ConfinementCarePage({super.key});

  @override
  State<ConfinementCarePage> createState() => _ConfinementCarePageState();
}

class _ConfinementCarePageState extends State<ConfinementCarePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        title: const Text(
          "Confinement Care",
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
            children: [
              _ConfinementCard(
                title: "Professional Care (7 Days)",
                desc:
                    "Professional care for mother and baby, supportive recovery and giving a peace of mind.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const Confinement7daysPage()),
                  );
                },
              ),
              const SizedBox(height: 14),
              _ConfinementCard(
                title: "Professional Care (10 Days)",
                desc:
                    "Professional care for mother and baby, supportive recovery and giving a peace of mind.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const Confinement10daysPage()),
                  );
                },
              ),
              const SizedBox(height: 14),
              _ConfinementCard(
                title: "Professional Care (14 Days)",
                desc:
                    "Professional care for mother and baby, supportive recovery and giving a peace of mind.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const Confinement14daysPage()),
                  );
                },
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfinementCard extends StatelessWidget {
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _ConfinementCard({
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 251, 182, 183),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/baby_blue.png',
                height: 70,
                width: 70,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: "Calsans",
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      maxLines: 3,
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
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            width: 150,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 251, 247, 247),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Book Now",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Calsans",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
