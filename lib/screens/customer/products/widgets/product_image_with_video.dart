import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '/core/utils/formatters.dart';

import 'mini_video_player.dart';

class ProductImageWithVideo extends StatelessWidget {
  final String imageUrl;
  final String videoUrl;

  const ProductImageWithVideo({
    super.key,
    required this.imageUrl,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = resolveImageUrl(imageUrl);
    final resolvedVideoUrl = resolveImageUrl(videoUrl);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 200,
            child: Image.network(
              resolvedImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image),
            ),
          ),
        ),

        // Show mini video preview if URL exists
        if (resolvedVideoUrl.isNotEmpty)
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _showFullScreenVideo(context, resolvedVideoUrl),
              child: const Hero(
                tag: 'video-player',
                child: MiniVideoPlayer(
                  videoUrl: '', // passed dynamically below
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenVideo(BuildContext context, String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(videoUrl: videoUrl),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isReady = true);
          _controller.play();
        }
      });
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
      body: Center(
        child:
            _isReady
                ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
