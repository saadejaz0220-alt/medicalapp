import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/models/media_item.dart';

class EmbeddedMediaPlayer extends StatefulWidget {
  final MediaItem media;
  final void Function(double percentage) onProgressUpdate;
  final VoidCallback onClose;

  const EmbeddedMediaPlayer({
    required Key key, // Use key to force rebuild
    required this.media,
    required this.onProgressUpdate,
    required this.onClose,
  }) : super(key: key);

  @override
  State<EmbeddedMediaPlayer> createState() => _EmbeddedMediaPlayerState();
}

class _EmbeddedMediaPlayerState extends State<EmbeddedMediaPlayer> {
  // Youtube
  YoutubePlayerController? _youtubeController;
  
  // Video/Audio
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _errorMessage;
  
  double _lastPercentage = 0;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    setState(() {
      _isInitialized = false;
      _errorMessage = null;
      _lastPercentage = widget.media.progress;
    });

    if (widget.media.isYoutube) {
      try {
        _youtubeController = YoutubePlayerController(
          initialVideoId: widget.media.youtubeId!,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        )..addListener(_updateProgress);
        setState(() => _isInitialized = true);
      } catch (e) {
        setState(() => _errorMessage = 'YouTube Init Error: $e');
      }
    } else if (widget.media.url.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.media.url));
      _videoPlayerController!.initialize().then((_) {
        if (!mounted) return;
        _videoPlayerController!.addListener(_updateProgress);
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            aspectRatio: _videoPlayerController!.value.aspectRatio > 0 
                ? _videoPlayerController!.value.aspectRatio 
                : 16 / 9,
            materialProgressColors: ChewieProgressColors(
              playedColor: Theme.of(context).colorScheme.primary,
              handleColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey.shade300,
            ),
          );
          _isInitialized = true;
        });
      }).catchError((error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Video Library Error: $error';
          _isInitialized = false;
        });
        debugPrint('Error initializing video player: $error');
      });
    } else {
      setState(() => _errorMessage = 'No valid media URL found');
    }
  }

  void _updateProgress() {
    if (!mounted) return;
    double percentage = 0.0;
    
    if (widget.media.isYoutube && _youtubeController != null) {
      final total = _youtubeController!.metadata.duration.inSeconds;
      final current = _youtubeController!.value.position.inSeconds;
      if (total > 0) {
        percentage = (current / total) * 100;
      }
    } else if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      final total = _videoPlayerController!.value.duration.inSeconds;
      final current = _videoPlayerController!.value.position.inSeconds;
      if (total > 0) {
        percentage = (current / total) * 100;
      }
    }
    
    final clamped = percentage.clamp(0.0, 100.0);
    if (clamped != _lastPercentage) {
      _lastPercentage = clamped;
    }
  }

  void _handleClose() {
    if (_closed) return;
    _closed = true;
    _updateProgress(); // Final update
    
    // Wrap in post-frame callback to avoid "widget tree locked" error during unmount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onProgressUpdate(_lastPercentage);
    });
    
    widget.onClose();
  }

  void _disposeCurrentPlayer() {
    _youtubeController?.removeListener(_updateProgress);
    try {
      _youtubeController?.pause();
    } catch (_) {}
    _youtubeController?.dispose();
    _youtubeController = null;

    try {
      _chewieController?.pause();
    } catch (_) {}
    _chewieController?.dispose();
    _chewieController = null;

    _videoPlayerController?.removeListener(_updateProgress);
    try {
      _videoPlayerController?.pause();
    } catch (_) {}
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    // If not closed via button, report progress now (barrier dismiss)
    if (!_closed) {
      final finalPercentage = _lastPercentage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onProgressUpdate(finalPercentage);
      });
    }
    _disposeCurrentPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2.0, strokeAlign: BorderSide.strokeAlignOutside),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Title and Close Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.black87,
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.media.title,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: _handleClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Player Area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: _initializePlayer,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : !_isInitialized
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Loading your session...', style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        )
                      : widget.media.isYoutube
                          ? YoutubePlayer(
                              controller: _youtubeController!,
                              showVideoProgressIndicator: true,
                            )
                          : _chewieController != null
                              ? Chewie(controller: _chewieController!)
                              : const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
            ),
          ),
        ],
      ),
    );
  }
}

