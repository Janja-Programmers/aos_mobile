import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/core/routing/helpers/route_observer.dart';

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
    _maybeInitInlineVideo();
    _startAutoScrollIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
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

  /// ===============================
  /// APP LIFECYCLE
  /// ===============================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _vc?.pause();
      _chewieController?.pause();
    }
  }

  /// ===============================
  /// ROUTE AWARE
  /// ===============================
  @override
  void didPushNext() {
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

      final current = widget.selected.clamp(0, media.length - 1);
      final next = (current + 1) % media.length;

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
      };

      controller.addListener(_videoListener!);

      if (mounted) setState(() {});
    });

    if (mounted) setState(() {});
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
                : PageView.builder(
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

                      final vc = (isActive && item.isVideo) ? _vc : null;
                      final init = (isActive && item.isVideo) ? _init : null;

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

// class _Thumb extends StatelessWidget {
//   const _Thumb({
//     required this.item,
//     required this.active,
//     required this.colors,
//     required this.onTap,
//     this.videoPoster,
//   });

//   final _MediaItem item;
//   final bool active;
//   final AppColorTokens colors;
//   final VoidCallback onTap;
//   final String? videoPoster;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appColors;
//     final borderColor = active
//         ? colors.primary
//         : Theme.of(context).dividerColor.withOpacity(0.2);

//     final Widget content;

//     if (!item.isVideo) {
//       content = Image.network(
//         buildFileUrl(item.url) ?? '',
//         fit: BoxFit.cover,
//         errorBuilder: (_, _, _) =>
//             const Center(child: Icon(Icons.broken_image_outlined, size: 18)),
//       );
//     } else {
//       final poster = (videoPoster ?? '').trim();
//       content = Stack(
//         fit: StackFit.expand,
//         children: [
//           if (poster.isNotEmpty)
//             Image.network(
//               buildFileUrl(poster) ?? '',
//               fit: BoxFit.cover,
//               errorBuilder: (_, _, _) => const Center(
//                 child: Icon(Icons.broken_image_outlined, size: 18),
//               ),
//             )
//           else
//             const Center(child: Icon(Icons.videocam_outlined, size: 18)),
//           Container(color: colors.black.withOpacity(0.12)),
//           Center(
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: colors.black.withOpacity(0.45),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.play_arrow_rounded,
//                 size: 18,
//                 color: colors.surface,
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         height: 62,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: borderColor, width: active ? 2 : 1),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: content,
//         ),
//       ),
//     );
//   }
// }
