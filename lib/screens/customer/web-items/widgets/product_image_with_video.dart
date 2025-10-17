import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '/core/utils/formatters.dart';

import 'mini_video_player.dart';

class ProductImageWithVideo extends StatefulWidget {
  final List<String> imageUrls;
  final String videoUrl;

  const ProductImageWithVideo({
    super.key,
    required this.imageUrls,
    required this.videoUrl,
  });

  @override
  State<ProductImageWithVideo> createState() => _ProductImageWithVideoState();
}

class _ProductImageWithVideoState extends State<ProductImageWithVideo> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final images =
        widget.imageUrls.map(resolveImageUrl).whereType<String>().toList();

    final videoUrl = resolveImageUrl(widget.videoUrl);

    final isCarousel = images.length > 1;

    // Always show the first image or fallback
    final mainImage = images.isNotEmpty ? images.first : null;

    return Column(
      children: [
        Stack(
          children: [
            // Image area
            isCarousel
                ? CarouselSlider(
                  items:
                      images.map((imgUrl) {
                        return GestureDetector(
                          onTap: () => _openFullscreen(context, imgUrl),
                          child: _buildImage(imgUrl),
                        );
                      }).toList(),
                  options: CarouselOptions(
                    height: 220,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    onPageChanged:
                        (index, _) => setState(() => _current = index),
                  ),
                )
                : GestureDetector(
                  onTap: () => _openFullscreen(context, mainImage ?? ""),
                  child: _buildImage(mainImage),
                ),

            // Video button overlay
            if (videoUrl != null && videoUrl.isNotEmpty)
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _showFullScreenVideo(context, videoUrl),
                  child: Hero(
                    tag: 'video-player',
                    child: MiniVideoPlayer(videoUrl: videoUrl),
                  ),
                ),
              ),
          ],
        ),

        // Carousel indicators
        if (isCarousel)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _current == entry.key
                              ? Colors.black
                              : Colors.grey.shade400,
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty || !url.contains('/files/')) {
      return _fallbackImage();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: double.infinity,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _fallbackImage(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _fallbackImage({double height = 220}) {
    return Container(
      height: height,
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  void _openFullscreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
      ),
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
    _videoController = VideoPlayerController.network(widget.videoUrl);
    _videoController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowedScreenSleep: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child:
            _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(),
      ),
    );
  }
}
