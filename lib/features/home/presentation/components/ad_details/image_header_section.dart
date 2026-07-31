import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/route_observer.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/presentation/components/ad_details/image_header_widgets.dart';
import 'package:africaonlinestores/features/home/presentation/services/ad_image_export_service.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class ImageHeaderSection extends StatefulWidget {
  const ImageHeaderSection({
    super.key,
    required this.images,
    required this.selected,
    required this.onSelect,
    this.videoUrl,
    this.isFavorite = false,
    this.isFavoritePending = false,
    this.onFavoriteTap,
    this.onShareTap,
  });

  final List<String> images;
  final String? videoUrl;

  final int selected;
  final ValueChanged<int> onSelect;

  final bool isFavorite;
  final bool isFavoritePending;

  final VoidCallback? onFavoriteTap;
  final VoidCallback? onShareTap;

  @override
  State<ImageHeaderSection> createState() => _ImageHeaderSectionState();
}

class _ImageHeaderSectionState extends State<ImageHeaderSection>
    with WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  VoidCallback? _videoListener;

  Future<void>? _videoInitialization;
  String? _currentVideoUrl;

  int _videoGeneration = 0;
  bool _videoCompletionHandled = false;

  late final PageController _pageController;
  late int _currentIndex;

  ModalRoute<void>? _subscribedRoute;

  Timer? _autoScrollTimer;

  static const Duration _autoScrollInterval = Duration(seconds: 4);

  bool get _hasVideo => (widget.videoUrl ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    final media = _buildMedia();

    _currentIndex = _safeIndex(widget.selected, media.length);

    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _maybeInitializeInlineVideo(_currentIndex);
      _startAutoScrollIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant ImageHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final imagesChanged = !listEquals(oldWidget.images, widget.images);

    final videoChanged = oldWidget.videoUrl != widget.videoUrl;
    final selectedChanged = oldWidget.selected != widget.selected;

    if (!imagesChanged && !videoChanged && !selectedChanged) {
      return;
    }

    final media = _buildMedia();

    if (media.isEmpty) {
      _currentIndex = 0;
      _stopAutoScroll();
      _disposeInlineVideo();
      return;
    }

    final previousIndex = _currentIndex;

    if (selectedChanged) {
      _currentIndex = _safeIndex(widget.selected, media.length);
    } else {
      _currentIndex = _safeIndex(_currentIndex, media.length);
    }

    if (_currentIndex != previousIndex || selectedChanged) {
      _moveToPage(_currentIndex);
    }

    _maybeInitializeInlineVideo(_currentIndex);
    _startAutoScrollIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of<void>(context);

    if (route == null || identical(route, _subscribedRoute)) {
      return;
    }

    routeObserver.unsubscribe(this);

    _subscribedRoute = route;
    routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    _stopAutoScroll();
    _disposeInlineVideo();

    _pageController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resumeSelectedMedia();

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _pauseVideo();
        _stopAutoScroll();
    }
  }

  @override
  void didPushNext() {
    _pauseVideo();
    _stopAutoScroll();
  }

  @override
  void didPopNext() {
    _resumeSelectedMedia();
  }

  void _resumeSelectedMedia() {
    if (!mounted) return;

    final media = _buildMedia();

    if (media.isEmpty) return;

    final index = _safeIndex(_currentIndex, media.length);

    _maybeInitializeInlineVideo(index);
    _startAutoScrollIfNeeded();
  }

  void _pauseVideo() {
    final chewieController = _chewieController;

    if (chewieController != null) {
      unawaited(chewieController.pause());
      return;
    }

    unawaited(_videoController?.pause());
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _startAutoScrollIfNeeded() {
    _stopAutoScroll();

    final media = _buildMedia();

    if (media.length <= 1) return;

    final current = _safeIndex(_currentIndex, media.length);

    if (media[current].isVideo) {
      return;
    }

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final latestMedia = _buildMedia();

      if (latestMedia.length <= 1) {
        _stopAutoScroll();
        return;
      }

      final latestCurrent = _safeIndex(_currentIndex, latestMedia.length);

      if (latestMedia[latestCurrent].isVideo) {
        _stopAutoScroll();
        return;
      }

      final next = (latestCurrent + 1) % latestMedia.length;

      _selectMedia(next);
    });
  }

  void _disposeInlineVideo() {
    _videoGeneration++;
    _videoCompletionHandled = false;

    final videoController = _videoController;
    final chewieController = _chewieController;
    final videoListener = _videoListener;

    _videoController = null;
    _chewieController = null;
    _videoListener = null;
    _videoInitialization = null;
    _currentVideoUrl = null;

    try {
      if (videoListener != null) {
        videoController?.removeListener(videoListener);
      }
    } catch (_) {
      // Best effort.
    }

    try {
      unawaited(chewieController?.pause());
      chewieController?.dispose();
    } catch (_) {
      // Best effort.
    }

    try {
      unawaited(videoController?.pause());
      unawaited(videoController?.dispose());
    } catch (_) {
      // Best effort.
    }
  }

  List<String> _visibleImages() {
    return widget.images
        .map((image) => image.trim())
        .where((image) => image.isNotEmpty)
        .take(4)
        .toList(growable: false);
  }

  List<ImageHeaderMediaItem> _buildMedia() {
    final visibleImages = _visibleImages();

    return [
      for (final image in visibleImages) ImageHeaderMediaItem.image(image),
      if (_hasVideo) ImageHeaderMediaItem.video(widget.videoUrl!.trim()),
    ];
  }

  void _maybeInitializeInlineVideo(int selectedIndex) {
    final media = _buildMedia();

    if (media.isEmpty) {
      if (_videoController != null ||
          _chewieController != null ||
          _videoInitialization != null) {
        _disposeInlineVideo();

        if (mounted) {
          setState(() {});
        }
      }

      return;
    }

    final safeSelected = _safeIndex(selectedIndex, media.length);

    final selectedItem = media[safeSelected];

    if (!selectedItem.isVideo) {
      if (_videoController != null ||
          _chewieController != null ||
          _videoInitialization != null) {
        _disposeInlineVideo();

        if (mounted) {
          setState(() {});
        }
      }

      return;
    }

    final resolvedUrl = (buildFileUrl(selectedItem.url) ?? '').trim();

    if (resolvedUrl.isEmpty) {
      _disposeInlineVideo();

      if (mounted) {
        setState(() {});
      }

      return;
    }

    final existingController = _videoController;

    if (existingController != null && _currentVideoUrl == resolvedUrl) {
      if (existingController.value.isInitialized) {
        _videoCompletionHandled = false;

        unawaited(_resumeExistingVideo(existingController, _videoGeneration));
      }

      return;
    }

    _disposeInlineVideo();

    final controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl));

    final generation = ++_videoGeneration;

    _videoController = controller;
    _currentVideoUrl = resolvedUrl;
    _videoCompletionHandled = false;

    _videoInitialization = _initializeInlineVideo(
      controller: controller,
      generation: generation,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeInlineVideo({
    required VideoPlayerController controller,
    required int generation,
  }) async {
    try {
      await controller.initialize();

      if (!_isCurrentVideoController(controller, generation)) {
        return;
      }

      await controller.setLooping(false);

      if (!_isCurrentVideoController(controller, generation)) {
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        allowPlaybackSpeedChanging: false,
      );

      if (!_isCurrentVideoController(controller, generation)) {
        chewieController.dispose();
        return;
      }

      _chewieController = chewieController;

      void listener() {
        if (!_isCurrentVideoController(controller, generation) ||
            _videoCompletionHandled ||
            !controller.value.isInitialized) {
          return;
        }

        final position = controller.value.position;
        final duration = controller.value.duration;

        if (duration == Duration.zero) {
          return;
        }

        final threshold = duration > const Duration(milliseconds: 150)
            ? duration - const Duration(milliseconds: 150)
            : duration;

        if (position < threshold) {
          return;
        }

        _videoCompletionHandled = true;

        unawaited(controller.pause());

        final media = _buildMedia();

        if (media.length <= 1) {
          return;
        }

        final next =
            (_safeIndex(_currentIndex, media.length) + 1) % media.length;

        scheduleMicrotask(() {
          if (!mounted || !_isCurrentVideoController(controller, generation)) {
            return;
          }

          _selectMedia(next);
        });
      }

      _videoListener = listener;
      controller.addListener(listener);

      if (mounted) {
        setState(() {});
      }
    } catch (error, stackTrace) {
      if (!_isCurrentVideoController(controller, generation)) {
        return;
      }

      appLogger.e(
        'Inline ad video initialization failed',
        error: error,
        stackTrace: stackTrace,
      );

      _disposeInlineVideo();

      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _resumeExistingVideo(
    VideoPlayerController controller,
    int generation,
  ) async {
    try {
      if (!_isCurrentVideoController(controller, generation) ||
          !controller.value.isInitialized) {
        return;
      }

      final duration = controller.value.duration;
      final position = controller.value.position;

      if (duration != Duration.zero) {
        final restartThreshold = duration > const Duration(milliseconds: 150)
            ? duration - const Duration(milliseconds: 150)
            : duration;

        if (position >= restartThreshold) {
          await controller.seekTo(Duration.zero);
        }
      }

      if (!_isCurrentVideoController(controller, generation)) {
        return;
      }

      if (!controller.value.isPlaying) {
        await controller.play();
      }
    } catch (error, stackTrace) {
      if (!_isCurrentVideoController(controller, generation)) {
        return;
      }

      appLogger.w(
        'Unable to resume inline ad video',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool _isCurrentVideoController(
    VideoPlayerController controller,
    int generation,
  ) {
    return mounted &&
        generation == _videoGeneration &&
        identical(_videoController, controller);
  }

  void _selectMedia(int index) {
    final media = _buildMedia();

    if (media.isEmpty) return;

    final safeIndex = _safeIndex(index, media.length);

    _stopAutoScroll();

    if (_currentIndex != safeIndex && mounted) {
      setState(() {
        _currentIndex = safeIndex;
      });
    }

    if (widget.selected != safeIndex) {
      widget.onSelect(safeIndex);
    }

    _moveToPage(safeIndex);
    _maybeInitializeInlineVideo(safeIndex);
    _startAutoScrollIfNeeded();
  }

  void _moveToPage(int index) {
    void animate() {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final page = _pageController.page;

      if (page != null && (page - index).abs() < 0.01) {
        return;
      }

      unawaited(
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        ),
      );
    }

    if (_pageController.hasClients) {
      animate();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      animate();
    });
  }

  Future<void> _openFullScreenImage(int initialImageIndex) async {
    final images = _visibleImages();

    if (images.isEmpty) return;

    final safeIndex = _safeIndex(initialImageIndex, images.length);

    _pauseVideo();
    _stopAutoScroll();

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) {
          return FullScreenImageViewer(images: images, initialIndex: safeIndex);
        },
      ),
    );

    if (mounted) {
      _resumeSelectedMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = _buildMedia();

    final safeSelected = _safeIndex(_currentIndex, media.length);

    final visibleImages = _visibleImages();

    final posterImage = visibleImages.isEmpty ? null : visibleImages.first;

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
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.08),
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

                            if (_currentIndex != index && mounted) {
                              setState(() {
                                _currentIndex = index;
                              });
                            }

                            if (widget.selected != index) {
                              widget.onSelect(index);
                            }

                            _maybeInitializeInlineVideo(index);
                            _startAutoScrollIfNeeded();
                          },
                          itemBuilder: (_, index) {
                            final item = media[index];
                            final isActive = index == safeSelected;

                            return ImageHeaderMainMedia(
                              item: item,
                              posterImage: posterImage,
                              videoController: isActive && item.isVideo
                                  ? _videoController
                                  : null,
                              init: isActive && item.isVideo
                                  ? _videoInitialization
                                  : null,
                              chewieController: isActive && item.isVideo
                                  ? _chewieController
                                  : null,
                              onImageTap: item.isVideo
                                  ? null
                                  : () {
                                      _openFullScreenImage(index);
                                    },
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ImageHeaderOverlayActions(
                    isFavorite: widget.isFavorite,
                    isFavoritePending: widget.isFavoritePending,
                    onShareTap: widget.onShareTap,
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

class FullScreenImageViewer extends ConsumerStatefulWidget {
  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  ConsumerState<FullScreenImageViewer> createState() {
    return _FullScreenImageViewerState();
  }
}

class _FullScreenImageViewerState extends ConsumerState<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();

    _currentIndex = _safeIndex(widget.initialIndex, widget.images.length);

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _downloadCurrentImage() async {
    if (_isDownloading || widget.images.isEmpty) {
      return;
    }

    final safeIndex = _safeIndex(_currentIndex, widget.images.length);

    setState(() {
      _isDownloading = true;
    });

    try {
      final service = ref.read(adImageExportServiceProvider);

      await service.saveImageToGallery(imageUrl: widget.images[safeIndex]);

      if (!mounted) return;

      ShowSnack(context, context.l10n.ad_media_saved_to_gallery).success();
    } on AdImageExportException catch (error) {
      if (!mounted) return;

      ShowSnack(context, error.message).error();
    } catch (error, stackTrace) {
      appLogger.e(
        'Unexpected full-screen image download failure',
        error: error,
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      final detail = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      final message = detail.isEmpty
          ? 'Unexpected image-download error '
                '(${error.runtimeType}).'
          : 'Unexpected image-download error '
                '(${error.runtimeType}): $detail';

      ShowSnack(context, message).error();
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.images.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.white,
                        size: 44,
                      ),
                    )
                  : PhotoViewGallery.builder(
                      pageController: _pageController,
                      itemCount: widget.images.length,
                      scrollPhysics: const BouncingScrollPhysics(),
                      backgroundDecoration: BoxDecoration(color: colors.black),
                      onPageChanged: (index) {
                        if (_currentIndex == index) {
                          return;
                        }

                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      loadingBuilder: (_, event) {
                        final expected = event?.expectedTotalBytes;

                        final loaded = event?.cumulativeBytesLoaded ?? 0;

                        return Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colors.white,
                              value: expected == null || expected <= 0
                                  ? null
                                  : loaded / expected,
                            ),
                          ),
                        );
                      },
                      builder: (_, index) {
                        final resolvedUrl =
                            (buildFileUrl(widget.images[index]) ?? '').trim();

                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(resolvedUrl),
                          initialScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 4,
                          errorBuilder: (_, _, _) {
                            return Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: colors.white,
                                size: 42,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _FullScreenActionButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: Icons.close,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _FullScreenActionButton(
                tooltip: context.l10n.ad_media_download_image,
                icon: Icons.download_outlined,
                isLoading: _isDownloading,
                onPressed: _isDownloading || widget.images.isEmpty
                    ? null
                    : _downloadCurrentImage,
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / '
                      '${widget.images.length}',
                      style: TextStyle(
                        color: colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenActionButton extends StatelessWidget {
  const _FullScreenActionButton({
    required this.tooltip,
    required this.icon,
    this.isLoading = false,
    this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colors.white,
                      ),
                    )
                  : Icon(icon, color: colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

int _safeIndex(int requestedIndex, int itemCount) {
  if (itemCount <= 0) {
    return 0;
  }

  if (requestedIndex < 0) {
    return 0;
  }

  if (requestedIndex >= itemCount) {
    return itemCount - 1;
  }

  return requestedIndex;
}
