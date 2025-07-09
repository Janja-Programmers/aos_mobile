import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
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
        widget.imageUrls
            .where((url) => url.trim().isNotEmpty)
            .map(resolveImageUrl)
            .toList();

    if (kDebugMode) {
      print('🖼 Resolved image URLs: $images');
    }

    final videoUrl = resolveImageUrl(widget.videoUrl);

    if (images.isEmpty) {
      return _fallbackImage();
    }

    final isCarousel = images.length > 1;

    return Column(
      children: [
        Stack(
          children: [
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
                  onTap: () => _openFullscreen(context, images.first),
                  child: _buildImage(images.first),
                ),

            if (videoUrl.isNotEmpty)
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

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackImage(),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.grey.shade200,
      height: 220,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
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
