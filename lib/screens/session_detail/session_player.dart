import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/session_model.dart';

class SessionPlayerScreen extends StatefulWidget {
  const SessionPlayerScreen({super.key});

  @override
  State<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    final session = Get.arguments as Session?;

    final videoUrl = session?.videoUrl ??
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'; // fallback

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    _videoPlayerController.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey.shade300,
          ),
          // You can customize more: showControlsOnInitialize, placeholder, etc.
        );
      });
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to load video: $error');
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Session Playback'),
        backgroundColor: Colors.black54,
      ),
      body: SafeArea(
        child: Center(
          child: _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading video...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}