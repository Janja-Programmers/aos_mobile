import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/full_screen_video_page.dart';

class ImageHeaderSection extends StatefulWidget {
  const ImageHeaderSection({
    super.key,
    required this.images,
    required this.selected,
    required this.onSelect,
    this.videoUrl,
  });

  final List<String> images;
  final String? videoUrl;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  State<ImageHeaderSection> createState() => _ImageHeaderSectionState();
}

class _ImageHeaderSectionState extends State<ImageHeaderSection> {
  VideoPlayerController? _vc;
  Future<void>? _init;
  String? _currentVideoUrl;

  late final PageController _pageController;

  Timer? _autoScrollTimer;
  static const Duration _autoScrollInterval = Duration(seconds: 4);

  bool get _hasVideo => (widget.videoUrl ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selected);
    _maybeInitInlineVideo();
    _startAutoScrollIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ImageHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldVideo = (oldWidget.videoUrl ?? '').trim();
    final newVideo = (widget.videoUrl ?? '').trim();

    final selectionChanged = oldWidget.selected != widget.selected;
    final videoChanged = oldVideo != newVideo;
    final imagesChanged = oldWidget.images != widget.images;

    if (selectionChanged) {
      _jumpToPageSafe(widget.selected);
    }

    if (selectionChanged || videoChanged || imagesChanged) {
      _maybeInitInlineVideo();
      _startAutoScrollIfNeeded();
    }
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _disposeInline();
    _pageController.dispose();
    super.dispose();
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _startAutoScrollIfNeeded() {
    _stopAutoScroll();

    final media = _buildMedia();
    if (media.length <= 1) return;

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;

      final current = widget.selected.clamp(0, media.length - 1);
      final next = (current + 1) % media.length;

      // Keep parent state in sync
      widget.onSelect(next);

      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _disposeInline() {
    _vc?.dispose();
    _vc = null;
    _init = null;
    _currentVideoUrl = null;
  }

  List<_MediaItem> _buildMedia() {
    final cleanImages = widget.images
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final thumbImages = cleanImages.take(4);

    return <_MediaItem>[
      for (final img in thumbImages) _MediaItem.image(img),
      if (_hasVideo) _MediaItem.video(widget.videoUrl!.trim()),
    ];
  }

  void _maybeInitInlineVideo() {
    final media = _buildMedia();
    final safeSelected = media.isEmpty
        ? 0
        : widget.selected.clamp(0, media.length - 1);

    final selectedItem = media.isEmpty ? null : media[safeSelected];

    // Only keep controller when selected is video.
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
      controller
        ..setLooping(true)
        ..setVolume(0.0)
        ..play();
      if (mounted) setState(() {});
    });

    if (mounted) setState(() {});
  }

  void _openFullscreenVideo() {
    if (_currentVideoUrl == null || _currentVideoUrl!.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPage(
          videoPath: _currentVideoUrl!,
          thumbnailPath: widget.images.isNotEmpty ? widget.images.first : null,
        ),
      ),
    );
  }

  void _jumpToPageSafe(int index) {
    if (!_pageController.hasClients) return;

    final media = _buildMedia();
    if (media.isEmpty) return;

    final safe = index.clamp(0, media.length - 1);
    _pageController.jumpToPage(safe);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final media = _buildMedia();
    final safeSelected = media.isEmpty
        ? 0
        : widget.selected.clamp(0, media.length - 1);

    final posterImage = widget.images.isNotEmpty
        ? widget.images.first.trim()
        : null;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).dividerColor.withOpacity(0.08),
            ),
            clipBehavior: Clip.antiAlias,
            child: media.isEmpty
                ? const Center(child: Icon(Icons.image_outlined, size: 40))
                : (media.length == 1)
                ? _MainMediaOrInlineVideo(
                    item: media.first,
                    posterImage: posterImage,
                    vc: _vc,
                    init: _init,
                    onTapVideo: media.first.isVideo
                        ? _openFullscreenVideo
                        : null,
                  )
                : Stack(
                    children: [
                      NotificationListener<UserScrollNotification>(
                        onNotification: (n) {
                          // Pause while user is actively scrolling the carousel
                          if (n.direction != ScrollDirection.idle) {
                            _stopAutoScroll();
                          } else {
                            _startAutoScrollIfNeeded();
                          }
                          return false;
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: media.length,
                          onPageChanged: (i) {
                            _stopAutoScroll();
                            if (i != widget.selected) widget.onSelect(i);
                            _maybeInitInlineVideo();
                            _startAutoScrollIfNeeded();
                          },
                          itemBuilder: (_, i) {
                            final item = media[i];
                            final isActive = i == safeSelected;

                            // Only attach controller to active video page
                            final vc = (isActive && item.isVideo) ? _vc : null;
                            final init = (isActive && item.isVideo)
                                ? _init
                                : null;

                            return _MainMediaOrInlineVideo(
                              item: item,
                              posterImage: posterImage,
                              vc: vc,
                              init: init,
                              onTapVideo: item.isVideo
                                  ? _openFullscreenVideo
                                  : null,
                            );
                          },
                        ),
                      ),

                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(media.length, (i) {
                            final active = i == safeSelected;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: active ? 18 : 6,
                              decoration: BoxDecoration(
                                color: active
                                    ? colors.primary
                                    : Colors.white.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        if (media.length > 1)
          LayoutBuilder(
            builder: (context, c) {
              final itemCount = media.length;
              const gap = 10.0;
              final totalGaps = gap * (itemCount - 1);
              final rawW = (c.maxWidth - totalGaps) / itemCount;
              final tileW = rawW.clamp(44.0, 72.0);

              return Row(
                children: [
                  for (var i = 0; i < itemCount; i++) ...[
                    SizedBox(
                      width: tileW,
                      height: 62,
                      child: _Thumb(
                        item: media[i],
                        active: i == safeSelected,
                        colors: colors,
                        videoPoster: posterImage,
                        onTap: () {
                          _stopAutoScroll();
                          widget.onSelect(i);
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                          _maybeInitInlineVideo();
                          _startAutoScrollIfNeeded();
                        },
                      ),
                    ),
                    if (i != itemCount - 1) const SizedBox(width: gap),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }
}

class _MainMediaOrInlineVideo extends StatelessWidget {
  const _MainMediaOrInlineVideo({
    required this.item,
    required this.posterImage,
    required this.vc,
    required this.init,
    this.onTapVideo,
  });

  final _MediaItem item;
  final String? posterImage;
  final VideoPlayerController? vc;
  final Future<void>? init;
  final VoidCallback? onTapVideo;

  @override
  Widget build(BuildContext context) {
    if (!item.isVideo) {
      return Image.network(
        buildFileUrl(item.url) ?? '',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    final child = Stack(
      fit: StackFit.expand,
      children: [
        if (init == null || vc == null)
          _VideoPoster(posterImage: posterImage)
        else
          FutureBuilder<void>(
            future: init,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done ||
                  !vc!.value.isInitialized) {
                return _VideoPoster(posterImage: posterImage);
              }
              final size = vc!.value.size;
              return FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: VideoPlayer(vc!),
                ),
              );
            },
          ),

        Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fullscreen, color: Colors.white, size: 26),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (onTapVideo == null) return child;
    return InkWell(onTap: onTapVideo, child: child);
  }
}

class _VideoPoster extends StatelessWidget {
  const _VideoPoster({required this.posterImage});
  final String? posterImage;

  @override
  Widget build(BuildContext context) {
    final poster = (posterImage ?? '').trim();
    if (poster.isEmpty) {
      return const Center(child: Icon(Icons.videocam_outlined, size: 44));
    }
    return Image.network(
      buildFileUrl(poster) ?? '',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}

class _MediaItem {
  const _MediaItem._(this.kind, this.url);

  final _MediaKind kind;
  final String url;

  factory _MediaItem.image(String url) => _MediaItem._(_MediaKind.image, url);
  factory _MediaItem.video(String url) => _MediaItem._(_MediaKind.video, url);

  bool get isVideo => kind == _MediaKind.video;
}

enum _MediaKind { image, video }

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.item,
    required this.active,
    required this.colors,
    required this.onTap,
    this.videoPoster,
  });

  final _MediaItem item;
  final bool active;
  final ColorScheme colors;
  final VoidCallback onTap;
  final String? videoPoster;

  @override
  Widget build(BuildContext context) {
    final borderColor = active
        ? colors.primary
        : Theme.of(context).dividerColor.withOpacity(0.2);

    final Widget content;

    if (!item.isVideo) {
      content = Image.network(
        buildFileUrl(item.url) ?? '',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Icons.broken_image_outlined, size: 18)),
      );
    } else {
      final poster = (videoPoster ?? '').trim();
      content = Stack(
        fit: StackFit.expand,
        children: [
          if (poster.isNotEmpty)
            Image.network(
              buildFileUrl(poster) ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 18),
              ),
            )
          else
            const Center(child: Icon(Icons.videocam_outlined, size: 18)),
          Container(color: Colors.black.withOpacity(0.12)),
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: active ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
