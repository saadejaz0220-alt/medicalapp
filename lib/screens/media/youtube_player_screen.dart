// lib/presentation/screens/media/youtube_player_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../app/utils/youtube_utils.dart';


class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({super.key});

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  late String videoId;
  late String title;

  @override
  void initState() {
    super.initState();

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    String idOrUrl = args['videoId'] ?? 'dQw4w9WgXcQ';
    title = args['title'] ?? 'Now Playing';

    // Ensure we have a valid video ID (in case a full URL was passed)
    videoId = YoutubeUtils.convertUrlToId(idOrUrl) ?? (idOrUrl.length == 11 ? idOrUrl : 'dQw4w9WgXcQ');


    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        showLiveFullscreenButton: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // YouTube Player
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Theme.of(context).colorScheme.primary,
            topActions: [
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () {
                  _controller.toggleFullScreenMode();
                },
              ),
            ],
            bottomActions: [
              const Spacer(),
              CurrentPosition(),
              const ProgressBar(isExpanded: true),
              RemainingDuration(),
              const PlaybackSpeedButton(),
            ],
            onReady: () {
              _controller.addListener(() {
                if (_controller.value.playerState == PlayerState.ended) {
                  // Optional: mark as completed, unlock next content, etc.
                  print('Video completed!');
                }
              });
            },
          ),

          // Optional: Extra info below player
          Expanded(
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video ID: $videoId',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enjoy your guided session! Take your time and breathe deeply.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}