import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
      if (!mounted) return;
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    // If you want to temporarily disable audio on web (to avoid crash), uncomment:
    /*
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio playback is only available on mobile app for now.'),
        ),
      );
      return;
    }
    */

    final audioPath = widget.meditation['audio_path']?.toString();
    final url = getPublicAudioUrl(audioPath);

    if (url == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file not available')),
      );
      return;
    }

    debugPrint('Trying to play URL: $url');

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        if (!mounted) return;
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.stop();

        try {
          // Separate try/catch for source
          await _audioPlayer.setSourceUrl(
            url,
            mimeType: 'audio/mpeg',
          );
        } catch (e) {
          debugPrint('setSourceUrl error: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Browser cannot load this audio source.'),
            ),
          );
          return;
        }

        try {
          await _audioPlayer.resume();
        } catch (e) {
          debugPrint('resume error: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start audio playback.'),
            ),
          );
          return;
        }

        if (!mounted) return;
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      // last-resort catch
      debugPrint('Audio play error (outer): $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio playback error. Please try again.'),
        ),
      );
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

    int metaSeconds = 0;
    final rawDuration = widget.meditation['duration_seconds'];
    if (rawDuration is int) {
      metaSeconds = rawDuration;
    } else if (rawDuration is String) {
      metaSeconds = int.tryParse(rawDuration) ?? 0;
    }

    final total = _duration.inSeconds == 0 ? metaSeconds : _duration.inSeconds;

    final sliderMax = total > 0 ? total.toDouble() : 1.0;
    final sliderValue =
        _position.inSeconds.clamp(0, sliderMax.toInt()).toDouble();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
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
                'assets/images/meditate.png',
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
                      if (!mounted) return;
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
