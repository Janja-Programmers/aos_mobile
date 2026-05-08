import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/shop_now_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_bottom_info.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShortVideoPage extends StatefulWidget {
  final Short short;
  final bool isActive;
  final bool shouldPrepare;
  final bool isLikePending;
  final Future<void> Function(String shortId) onToggleLike;
  final void Function(String shortId) onCommentAdded;

  const ShortVideoPage({
    super.key,
    required this.short,
    required this.isActive,
    required this.shouldPrepare,
    required this.onToggleLike,
    required this.onCommentAdded,
    this.isLikePending = false,
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
      widget.isActive ? _play() : _pause();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
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

      await Future.wait([
        controller.initialize(),
        _detectThumbnailOrientation(),
      ]);

      await controller.setLooping(true);

      if (!mounted || !widget.shouldPrepare) {
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
    final url = widget.short.thumbnailUrl;

    if (url == null || url.isEmpty) {
      _usePortraitFrame = true;
      return;
    }

    final image = NetworkImage(url);
    final stream = image.resolve(const ImageConfiguration());
    final completer = Completer<ImageInfo>();

    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) {
          completer.complete(info);
        }
        stream.removeListener(listener);
      },
      onError: (_, _) {
        if (!completer.isCompleted) {
          completer.completeError('thumbnail failed');
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

      debugPrint(
        'THUMB ${widget.short.id} size=${width}x$height '
        'portrait=$_usePortraitFrame',
      );
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
  }

  Future<void> _pause() async {
    if (!_isInitialized || _controller == null) return;

    await _controller!.pause();

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
    });
  }

  void _disposeVideo() {
    final controller = _controller;
    _controller = null;

    controller?.pause();
    controller?.dispose();

    if (!mounted) return;

    setState(() {
      _isInitialized = false;
      _isPlaying = false;
      _hasError = false;
      _isInitializing = false;
      _usePortraitFrame = true;
    });
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: _togglePlayPause,
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
              isLikePending: widget.isLikePending,
              onToggleLike: widget.onToggleLike,
              onCommentAdded: widget.onCommentAdded,
            ),
          ),

          Positioned(
            left: 16,
            right: 90,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShortBottomInfo(short: widget.short),
                const SizedBox(height: 12),
                if (widget.short.ad != null) ShopNowCard(short: widget.short),
              ],
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
