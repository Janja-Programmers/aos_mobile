import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/shop_now_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_bottom_info.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShortVideoPage extends StatefulWidget {
  final Short short;
  final bool isActive;
  final bool shouldPrepare;

  final bool isLikedPending;
  final bool isFollowPending;
  final bool isSaved;
  final bool isSavePending;
  final bool isRepostPending;
  final bool isSharePending;
  final bool isDownloadPending;

  final Future<void> Function(String shortId) onToggleLike;
  final void Function(String shortId) onCommentAdded;
  final Future<void> Function(String targetUser)? onToggleFollow;
  final VoidCallback onCreatorTap;
  final Future<void> Function(String shortId) onRepost;
  final Future<void> Function(String shortId) onShare;
  final Future<void> Function(String shortId) onSave;
  final Future<void> Function(String shortId) onDownload;
  final Future<String?> Function({
    required String shortId,
    required String reason,
    required String details,
  })
  onReport;
  final void Function(String shortId) onImpression;
  final void Function({
    required String shortId,
    required int watchMs,
    bool force,
  })
  onWatchProgress;

  const ShortVideoPage({
    super.key,
    required this.short,
    required this.isActive,
    required this.shouldPrepare,
    required this.onToggleLike,
    required this.onCommentAdded,
    required this.onCreatorTap,
    required this.onRepost,
    required this.onShare,
    required this.onSave,
    required this.onDownload,
    required this.onReport,
    required this.onImpression,
    required this.onWatchProgress,
    this.onToggleFollow,
    this.isLikedPending = false,
    this.isFollowPending = false,
    this.isSaved = false,
    this.isSavePending = false,
    this.isRepostPending = false,
    this.isSharePending = false,
    this.isDownloadPending = false,
  });

  @override
  State<ShortVideoPage> createState() => _ShortVideoPageState();
}

class _ShortVideoPageState extends State<ShortVideoPage> {
  VideoPlayerController? _controller;

  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isInitializing = false;

  bool _usePortraitFrame = true;
  bool _showDoubleTapHeart = false;
  int _maxWatchMs = 0;
  int _lastForceTrackedMs = 0;
  bool _impressionSent = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();

    if (widget.shouldPrepare) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(covariant ShortVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.shouldPrepare && widget.shouldPrepare) {
      _initVideo();
    }

    if (oldWidget.shouldPrepare && !widget.shouldPrepare) {
      _disposeVideo();
      return;
    }

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _sendImpressionIfNeeded();
        _play();
      } else {
        _flushWatchProgress();
        _pause();
      }
    }
  }

  @override
  void dispose() {
    _disposeVideo(updateState: false);
    super.dispose();
  }

  Future<void> _initVideo() async {
    if (_controller != null || _isInitializing) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.short.playbackUrl),
      );

      _controller = controller;
      controller.addListener(_onVideoTick);

      await Future.wait<void>([
        controller.initialize(),
        _detectThumbnailOrientation(),
      ]);

      await controller.setLooping(true);
      await controller.setPlaybackSpeed(_playbackSpeed);

      if (!mounted || !widget.shouldPrepare) {
        controller.removeListener(_onVideoTick);
        if (_controller == controller) {
          _controller = null;
        }
        await controller.dispose();
        return;
      }

      setState(() {
        _isInitialized = true;
        _isInitializing = false;
      });

      if (widget.isActive) {
        await _play();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isInitializing = false;
      });

      debugPrint('Video init error: $e');
    }
  }

  Future<void> _detectThumbnailOrientation() async {
    // Future backend-assisted orientation path, intentionally commented until
    // the Shorts API exposes these fields:
    //
    // final orientation = widget.short.orientation?.trim().toLowerCase();
    // if (orientation == 'portrait') {
    //   _usePortraitFrame = true;
    //   return;
    // }
    // if (orientation == 'landscape') {
    //   _usePortraitFrame = false;
    //   return;
    // }
    //
    // final thumbnailWidth = widget.short.thumbnailWidth;
    // final thumbnailHeight = widget.short.thumbnailHeight;
    // if (thumbnailWidth != null &&
    //     thumbnailHeight != null &&
    //     thumbnailWidth > 0 &&
    //     thumbnailHeight > 0) {
    //   _usePortraitFrame = thumbnailHeight >= thumbnailWidth;
    //   return;
    // }

    final thumbnailUrl = widget.short.thumbnailUrl;

    if (thumbnailUrl == null || thumbnailUrl.trim().isEmpty) {
      _usePortraitFrame = true;
      return;
    }

    final ImageProvider<Object> image = AppImageDecode.networkProviderForPixels(
      thumbnailUrl,
      width: 96,
    );
    final stream = image.resolve(const ImageConfiguration());
    final completer = Completer<ImageInfo>();

    late final ImageStreamListener listener;

    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) {
          completer.complete(info);
        }
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);

    try {
      final info = await completer.future;
      final width = info.image.width;
      final height = info.image.height;

      _usePortraitFrame = height >= width;
    } catch (_) {
      _usePortraitFrame = true;
    }
  }

  Future<void> _play() async {
    if (!_isInitialized || _controller == null) return;

    await _controller!.play();

    if (!mounted) return;

    setState(() {
      _isPlaying = true;
    });

    _sendImpressionIfNeeded();
  }

  Future<void> _pause() async {
    if (!_isInitialized || _controller == null) return;

    await _controller!.pause();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });
  }

  void _disposeVideo({bool updateState = true}) {
    final controller = _controller;
    _controller = null;
    _isInitialized = false;
    _isPlaying = false;
    _hasError = false;
    _isInitializing = false;
    _usePortraitFrame = true;

    _flushWatchProgress();
    _maxWatchMs = 0;
    _lastForceTrackedMs = 0;

    if (controller != null) {
      controller.removeListener(_onVideoTick);
      unawaited(
        controller.pause().catchError((Object error, StackTrace stackTrace) {
          debugPrint('Video pause during dispose failed: $error');
        }),
      );

      unawaited(
        controller.dispose().catchError((Object error, StackTrace stackTrace) {
          debugPrint('Video dispose failed: $error');
        }),
      );
    }

    // Important:
    if (!updateState || !mounted) return;

    setState(() {});
  }

  void _sendImpressionIfNeeded() {
    if (_impressionSent || !widget.isActive) return;
    _impressionSent = true;
    widget.onImpression(widget.short.id.value);
  }

  void _onVideoTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (!widget.isActive || !controller.value.isPlaying) return;

    final positionMs = controller.value.position.inMilliseconds;
    if (positionMs > _maxWatchMs) {
      _maxWatchMs = positionMs;
    }

    final durationMs = controller.value.duration.inMilliseconds;
    final thresholdMs = _viewThresholdMs(durationMs);

    if (_maxWatchMs >= thresholdMs &&
        _maxWatchMs - _lastForceTrackedMs >= 5000) {
      _lastForceTrackedMs = _maxWatchMs;
      widget.onWatchProgress(
        shortId: widget.short.id.value,
        watchMs: _maxWatchMs,
        force: false,
      );
    }
  }

  int _viewThresholdMs(int durationMs) {
    if (durationMs <= 0) return 2000;
    final percentThreshold = (durationMs * .30).round();
    return percentThreshold < 2000 ? percentThreshold : 2000;
  }

  void _flushWatchProgress() {
    if (_maxWatchMs <= 0) return;
    widget.onWatchProgress(
      shortId: widget.short.id.value,
      watchMs: _maxWatchMs,
      force: true,
    );
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized || _controller == null || !widget.isActive) return;

    if (_controller!.value.isPlaying) {
      await _pause();
    } else {
      await _play();
    }
  }

  Widget _buildVideo() {
    final controller = _controller!;

    if (_usePortraitFrame) {
      return Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRect(child: VideoPlayer(controller)),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  Future<void> _handleDoubleTapLike() async {
    if (!widget.isActive) return;

    setState(() {
      _showDoubleTapHeart = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      setState(() {
        _showDoubleTapHeart = false;
      });
    });

    if (widget.short.isLiked || widget.isLikedPending) return;

    await widget.onToggleLike(widget.short.id.value);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    final supported = <double>{0.5, 0.75, 1, 1.25, 1.5, 2};
    if (!supported.contains(speed)) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setPlaybackSpeed(speed);
      if (!mounted || controller != _controller) return;
      setState(() => _playbackSpeed = speed);
    } catch (error) {
      debugPrint('Unable to change playback speed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayPause,
      onDoubleTap: _handleDoubleTapLike,
      onLongPress: () => showShortActionsSheet(
        context: context,
        short: widget.short,
        isSaved: widget.isSaved,
        isSavePending: widget.isSavePending,
        isRepostPending: widget.isRepostPending,
        isSharePending: widget.isSharePending,
        isDownloadPending: widget.isDownloadPending,
        onSave: () => widget.onSave(widget.short.id.value),
        onRepost: () => widget.onRepost(widget.short.id.value),
        onShare: () => widget.onShare(widget.short.id.value),
        onDownload: () => widget.onDownload(widget.short.id.value),
        onReport: widget.onReport,
        playbackSpeed: _playbackSpeed,
        onPlaybackSpeedChanged: (speed) => unawaited(_setPlaybackSpeed(speed)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: colors.black),

          if (_hasError)
            Center(
              child: Text(
                'Failed to load video',
                style: TextStyle(color: colors.white),
              ),
            )
          else if (!_isInitialized || _controller == null)
            const Center(child: CircularProgressIndicator())
          else
            _buildVideo(),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 120,
            child: ShortActionsPanel(
              short: widget.short,

              // Like
              isLikedPending: widget.isLikedPending,
              onToggleLike: widget.onToggleLike,

              // Comment
              onCommentAdded: widget.onCommentAdded,

              // Creator / seller
              onCreatorTap: widget.onCreatorTap,

              // Follow
              isFollowPending: widget.isFollowPending,
              onToggleFollow: widget.onToggleFollow,

              // Repost
              isRepostPending: widget.isRepostPending,
              onRepost: () => widget.onRepost(widget.short.id.value),

              // Share
              isSharePending: widget.isSharePending,
              onShare: () => widget.onShare(widget.short.id.value),

              // Save
              isSaved: widget.isSaved,
              isSavePending: widget.isSavePending,
              onSave: () => widget.onSave(widget.short.id.value),

              // More
              isDownloadPending: widget.isDownloadPending,
              onDownload: () => widget.onDownload(widget.short.id.value),
              onReport: widget.onReport,
              playbackSpeed: _playbackSpeed,
              onPlaybackSpeedChanged: (speed) =>
                  unawaited(_setPlaybackSpeed(speed)),
            ),
          ),

          Positioned(
            left: 16,
            right: 90,
            bottom: bottomPadding + 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShortBottomInfo(short: widget.short),
                const SizedBox(height: 12),
                if (widget.short.ad != null)
                  ShopNowCard(
                    short: widget.short,
                    onTap: () {
                      AdNavigation.toDetail(context, widget.short.ad!.id);
                    },
                  ),
              ],
            ),
          ),

          if (_showDoubleTapHeart)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.25),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Icon(
                  Icons.favorite_rounded,
                  color: colors.primary,
                  size: 112,
                ),
              ),
            ),

          if (_isInitialized && !_isPlaying && widget.isActive)
            Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: colors.white,
                size: 88,
              ),
            ),
        ],
      ),
    );
  }
}
