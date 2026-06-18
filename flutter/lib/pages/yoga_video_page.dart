import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';

class YogaVideoPage extends StatefulWidget {
  const YogaVideoPage({super.key});

  @override
  State<YogaVideoPage> createState() => _YogaVideoPageState();
}

class _YogaVideoPageState extends State<YogaVideoPage> {
  final String videoUrl = "https://www.youtube.com/watch?v=fmh58tykgpo";

  int userPoints = 0;
  bool canWatch = false;

  YoutubePlayerController? _controller;

  String getVideoId(String url) {
    final uri = Uri.parse(url);

    if (uri.queryParameters['v'] != null) {
      return uri.queryParameters['v']!;
    }

    return url.split('/').last;
  }

  @override
  void initState() {
    super.initState();
    loadPoints();

    if (!kIsWeb) {
      _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );

      _controller!.loadVideoById(
        videoId: getVideoId(videoUrl),
      );
    }
  }

  Future<void> loadPoints() async {
    final data = await ApiService.getPoints();

    setState(() {
      userPoints = data['data']['total_poin'] ?? 0;
      canWatch = userPoints >= 300;
    });
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Yoga Online Class"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =========================
            // 🔒 LOCK SYSTEM VIDEO
            // =========================
            if (!canWatch)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      "Video terkunci",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Poin kamu: $userPoints / 300",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              // =========================
              // 🎥 VIDEO PLAYER
              // =========================
              kIsWeb
                  ? Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final uri = Uri.parse(videoUrl);
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: const Text("Tonton Video"),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: YoutubePlayer(
                        controller: _controller!,
                        aspectRatio: 16 / 9,
                      ),
                    ),

            const SizedBox(height: 20),

            // =========================
            // 📊 INFO CARD
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.self_improvement,
                    size: 60,
                    color: Color(0xFF2979FF),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Yoga & Stretching",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Latihan yoga ringan selama ±15 menit untuk membantu mengontrol gula darah, meningkatkan fleksibilitas tubuh, dan mengurangi stres.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Poin kamu: $userPoints",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}