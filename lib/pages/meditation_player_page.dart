// meditation_player_page.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeditationPlayerPage extends StatefulWidget {
  final Map<String, dynamic> meditation;

  const MeditationPlayerPage({super.key, required this.meditation});

  @override
  State<MeditationPlayerPage> createState() => _MeditationPlayerPageState();
}

class _MeditationPlayerPageState extends State<MeditationPlayerPage> {
  final _supabase = Supabase.instance.client;
  late final AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String? getPublicAudioUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return _supabase.storage.from('sounds').getPublicUrl(path);
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final audioPath = widget.meditation['audio_path']?.toString();
    final url = getPublicAudioUrl(audioPath);

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file not available')),
      );
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() => _isPlaying = true);
    }
  }

  String _formatTime(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.meditation['title']?.toString() ?? 'Meditation';
    final subtitle =
        widget.meditation['subtitle']?.toString() ?? '7 DAYS OF CALM';

    final total = _duration.inSeconds == 0
        ? (widget.meditation['duration_seconds'] ?? 0) as int
        : _duration.inSeconds;

    final sliderMax = total > 0 ? total.toDouble() : 1.0;
    final sliderValue =
        _position.inSeconds.clamp(0, sliderMax.toInt()).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EE),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Illustration
            SizedBox(
              height: 180,
              child: Image.asset(
                'assets/images/meditation_illustration.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Calsans",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 60, 51, 76),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Raleway",
                fontSize: 13,
                color: Color.fromARGB(255, 140, 132, 150),
              ),
            ),
            const SizedBox(height: 32),

            // Big play button + optional knobs (just icons for now)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.refresh, size: 28, color: Colors.grey),
                  Icon(Icons.timer, size: 28, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 223, 206, 255),
                    Color.fromARGB(255, 173, 151, 233),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: InkWell(
                  onTap: _togglePlay,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 60, 51, 76),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Slider + time labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Slider(
                    value: sliderValue,
                    min: 0,
                    max: sliderMax,
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                      setState(() => _position = position);
                    },
                    activeColor: const Color.fromARGB(255, 173, 151, 233),
                    inactiveColor: Colors.grey.shade300,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(_position),
                        style: const TextStyle(
                          fontFamily: "Raleway",
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatTime(
                          Duration(seconds: total),
                        ),
                        style: const TextStyle(
                          fontFamily: "Raleway",
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
