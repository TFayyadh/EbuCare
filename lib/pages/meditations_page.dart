// meditation_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ebucare_app/pages/meditation_player_page.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchMeditations() async {
    final data = await _supabase
        .from('meditations') // change if your table name is different
        .select()
        .order('id', ascending: true);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header card with illustration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 224, 230),
                      Color.fromARGB(255, 255, 243, 230),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "CALM YOUR MIND",
                              style: TextStyle(
                                fontFamily: "Calsans",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 60, 51, 76),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Choose a calming sound and take a deep breath.",
                              style: TextStyle(
                                fontFamily: "Raleway",
                                fontSize: 12,
                                color: Color.fromARGB(255, 90, 80, 100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                          'assets/images/meditate.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: FutureBuilder<List<dynamic>>(
                  future: fetchMeditations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final meditations = snapshot.data ?? [];

                    print('Meditations from Supabase: $meditations');

                    if (meditations.isEmpty) {
                      return const Center(
                        child: Text(
                          "No meditation sounds available yet.",
                          style: TextStyle(
                            fontFamily: "Raleway",
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    final tileColors = <Color>[
                      const Color(0xFF4F8DFD),
                      const Color(0xFF35B286),
                      const Color(0xFFF2A03F),
                    ];

                    return ListView.builder(
                      itemCount: meditations.length,
                      itemBuilder: (context, index) {
                        final meditation =
                            meditations[index] as Map<String, dynamic>;
                        final color = tileColors[index % tileColors.length];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MeditationPlayerPage(
                                    meditation: meditation,
                                  ),
                                ),
                              );
                            },
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              meditation['title']?.toString() ??
                                  'Untitled session',
                              style: const TextStyle(
                                fontFamily: "Calsans",
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              meditation['subtitle']?.toString() ??
                                  'Relaxing sound',
                              style: const TextStyle(
                                fontFamily: "Raleway",
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.more_horiz,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
