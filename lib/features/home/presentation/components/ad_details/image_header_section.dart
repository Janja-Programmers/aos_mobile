import 'dart:async';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/rendering.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

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
  ChewieController? _chewieController;

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

    final current = widget.selected.clamp(0, media.length - 1);
    final item = media[current];

    if (item.isVideo) return;

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
    try {
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

    if (_vc != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _disposeInline();
      });
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(resolved));
    _vc = controller;
    _currentVideoUrl = resolved;

    _init = controller.initialize().then((_) {
      controller.initialize().then((_) {
        controller.setLooping(false);

        _chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowPlaybackSpeedChanging: false,
          showControls: true,
        );

        controller.addListener(() {
          if (!controller.value.isInitialized) return;

          final position = controller.value.position;
          final duration = controller.value.duration;

          if (position >= duration) {
            final media = _buildMedia();
            final next = (widget.selected + 1) % media.length;

            widget.onSelect(next);

            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );

            _startAutoScrollIfNeeded();
          }
        });

        if (mounted) setState(() {});
      });

      if (mounted) setState(() {});
    });

    if (mounted) setState(() {});
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
    final colors = context.appColors;

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
                    chewieController: _chewieController,
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
                              chewieController: _chewieController,
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
                                color: active ? colors.primary : colors.surface,
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
    required this.chewieController,
  });

  final _MediaItem item;
  final String? posterImage;
  final VideoPlayerController? vc;
  final Future<void>? init;
  final ChewieController? chewieController;

  @override
  Widget build(BuildContext context) {
    // IMAGE CASE
    if (!item.isVideo) {
      return Image.network(
        buildFileUrl(item.url) ?? '',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    // VIDEO CASE

    if (init == null || vc == null) {
      return _VideoPoster(posterImage: posterImage);
    }

    return FutureBuilder<void>(
      future: init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done ||
            vc == null ||
            !vc!.value.isInitialized) {
          return _VideoPoster(posterImage: posterImage);
        }

        if (chewieController == null) {
          return _VideoPoster(posterImage: posterImage);
        }

        return Chewie(controller: chewieController!);
      },
    );
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
  final AppColorTokens colors;
  final VoidCallback onTap;
  final String? videoPoster;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
          Container(color: colors.black.withOpacity(0.12)),
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 18,
                color: colors.surface,
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: content,
        ),
      ),
    );
  }
}
