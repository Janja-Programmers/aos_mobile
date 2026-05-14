import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/routing/helpers/route_observer.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_widgets.dart';

class ImageHeaderSection extends StatefulWidget {
  const ImageHeaderSection({
    super.key,
    required this.images,
    required this.selected,
    required this.onSelect,
    this.videoUrl,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onShareTap,
  });

  final List<String> images;
  final String? videoUrl;
  final int selected;
  final ValueChanged<int> onSelect;

  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onShareTap;

  @override
  State<ImageHeaderSection> createState() => _ImageHeaderSectionState();
}

class _ImageHeaderSectionState extends State<ImageHeaderSection>
    with WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _vc;
  ChewieController? _chewieController;
  VoidCallback? _videoListener;

  Future<void>? _init;
  String? _currentVideoUrl;

  late final PageController _pageController;

  Timer? _autoScrollTimer;
  static const Duration _autoScrollInterval = Duration(seconds: 4);

  bool get _hasVideo => (widget.videoUrl ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(initialPage: widget.selected);
    _maybeInitInlineVideo(widget.selected);
    _startAutoScrollIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ImageHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final media = _buildMedia();
    final safeSelected = media.isEmpty
        ? 0
        : widget.selected.clamp(0, media.length - 1);

    if (oldWidget.selected != widget.selected && _pageController.hasClients) {
      _pageController.animateToPage(
        safeSelected,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }

    if (oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.images != widget.images ||
        oldWidget.selected != widget.selected) {
      _maybeInitInlineVideo(safeSelected);
      _startAutoScrollIfNeeded();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    _stopAutoScroll();
    _disposeInline();
    _pageController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseVideo();
    }
  }

  @override
  void didPushNext() {
    _pauseVideo();
  }

  void _pauseVideo() {
    _vc?.pause();
    _chewieController?.pause();
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _startAutoScrollIfNeeded() {
    _stopAutoScroll();

    final media = _buildMedia();
    if (media.length <= 1) return;

    final current = widget.selected.clamp(0, media.length - 1);
    final item = media[current];

    if (item.isVideo) return;

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;

      final latestMedia = _buildMedia();
      if (latestMedia.length <= 1) return;

      final current = widget.selected.clamp(0, latestMedia.length - 1);
      final next = (current + 1) % latestMedia.length;

      widget.onSelect(next);

      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _disposeInline() {
    try {
      if (_videoListener != null) {
        _vc?.removeListener(_videoListener!);
        _videoListener = null;
      }

      _chewieController?.pause();
      _chewieController?.dispose();
    } catch (_) {}

    _chewieController = null;

    try {
      _vc?.pause();
      _vc?.dispose();
    } catch (_) {}

    _vc = null;
    _init = null;
    _currentVideoUrl = null;
  }

  List<ImageHeaderMediaItem> _buildMedia() {
    final cleanImages = widget.images
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final visibleImages = cleanImages.take(4);

    return <ImageHeaderMediaItem>[
      for (final image in visibleImages) ImageHeaderMediaItem.image(image),
      if (_hasVideo) ImageHeaderMediaItem.video(widget.videoUrl!.trim()),
    ];
  }

  void _maybeInitInlineVideo(int selectedIndex) {
    final media = _buildMedia();

    final safeSelected = media.isEmpty
        ? 0
        : selectedIndex.clamp(0, media.length - 1);

    final selectedItem = media.isEmpty ? null : media[safeSelected];

    if (selectedItem == null || !selectedItem.isVideo) {
      if (_vc != null) {
        _disposeInline();
        if (mounted) setState(() {});
      }
      return;
    }

    final resolved = (buildFileUrl(selectedItem.url) ?? '').trim();

    if (resolved.isEmpty) {
      if (_vc != null) {
        _disposeInline();
        if (mounted) setState(() {});
      }
      return;
    }

    if (_vc != null && _currentVideoUrl == resolved) {
      if (_vc!.value.isInitialized && !_vc!.value.isPlaying) {
        _vc!.play();
      }
      return;
    }

    _disposeInline();

    final controller = VideoPlayerController.networkUrl(Uri.parse(resolved));
    _vc = controller;
    _currentVideoUrl = resolved;

    _init = controller.initialize().then((_) {
      controller.setLooping(false);

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: false,
        showControls: true,
      );

      _videoListener = () {
        if (!controller.value.isInitialized) return;

        final position = controller.value.position;
        final duration = controller.value.duration;

        if (duration == Duration.zero) return;

        if (position >= duration) {
          final latestMedia = _buildMedia();
          if (latestMedia.isEmpty) return;

          final next = (widget.selected + 1) % latestMedia.length;

          widget.onSelect(next);

          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );

          _startAutoScrollIfNeeded();
        }
      };

      controller.addListener(_videoListener!);

      if (mounted) setState(() {});
    });

    if (mounted) setState(() {});
  }

  void _selectMedia(int index) {
    final media = _buildMedia();
    if (media.isEmpty) return;

    final safeIndex = index.clamp(0, media.length - 1);

    _stopAutoScroll();
    widget.onSelect(safeIndex);

    _pageController.animateToPage(
      safeIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );

    _maybeInitInlineVideo(safeIndex);
    _startAutoScrollIfNeeded();
  }

  void _openFullScreenImage(String imageUrl) {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty) return;

    _pauseVideo();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return FullScreenImageViewer(imageUrl: cleanUrl);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = _buildMedia();

    final safeSelected = media.isEmpty
        ? 0
        : widget.selected.clamp(0, media.length - 1);

    final posterImage = widget.images.isNotEmpty
        ? widget.images.first.trim()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1.28,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.08),
                  ),
                  child: media.isEmpty
                      ? const Center(
                          child: Icon(Icons.image_outlined, size: 40),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: media.length,
                          onPageChanged: (index) {
                            _stopAutoScroll();

                            if (index != widget.selected) {
                              widget.onSelect(index);
                            }

                            _maybeInitInlineVideo(index);
                            _startAutoScrollIfNeeded();
                          },
                          itemBuilder: (_, index) {
                            final item = media[index];
                            final isActive = index == safeSelected;

                            return ImageHeaderMainMedia(
                              item: item,
                              posterImage: posterImage,
                              videoController: isActive && item.isVideo
                                  ? _vc
                                  : null,
                              init: isActive && item.isVideo ? _init : null,
                              chewieController: isActive && item.isVideo
                                  ? _chewieController
                                  : null,
                              onImageTap: item.isVideo
                                  ? null
                                  : () => _openFullScreenImage(item.url),
                            );
                          },
                        ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: ImageHeaderOverlayActions(
                    isFavorite: widget.isFavorite,
                    onFavoriteTap: widget.onFavoriteTap,
                  ),
                ),

                if (media.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: ImageHeaderPageIndicators(
                      count: media.length,
                      selected: safeSelected,
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (media.isNotEmpty) ...[
          const SizedBox(height: 8),
          ImageHeaderThumbnailStrip(
            media: media,
            selected: safeSelected,
            posterImage: posterImage,
            onSelect: _selectMedia,
          ),
        ],
      ],
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final resolvedUrl = buildFileUrl(imageUrl) ?? '';

    return Scaffold(
      backgroundColor: colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                panEnabled: true,
                child: Center(
                  child: Image.network(
                    resolvedUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) {
                      return Icon(
                        Icons.broken_image_outlined,
                        color: colors.white,
                        size: 42,
                      );
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: Material(
                color: colors.black.withOpacity(0.45),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
