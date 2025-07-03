import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
    final hasImage = resolvedImageUrl.trim().isNotEmpty;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: 200,
            child:
                hasImage
                    ? Image.network(
                      resolvedImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, _) => _fallbackImage(),
                    )
                    : _fallbackImage(),
          ),
        ),

        // Mini Video Preview
        if (resolvedVideoUrl.isNotEmpty)
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _showFullScreenVideo(context, resolvedVideoUrl),
              child: Hero(
                tag: 'video-player',
                child: MiniVideoPlayer(videoUrl: resolvedVideoUrl),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
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
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _videoController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowedScreenSleep: false,
        fullScreenByDefault: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
      );

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child:
            _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(),
      ),
    );
  }
}
