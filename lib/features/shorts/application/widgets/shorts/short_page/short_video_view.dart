import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class ShortVideoView extends StatefulWidget {
  final VideoPlayerController? controller;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const ShortVideoView({
    super.key,
    required this.controller,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<ShortVideoView> createState() => _ShortVideoViewState();
}

class _ShortVideoViewState extends State<ShortVideoView> {
  bool _isPlaying = false;
  bool _isBuffering = true;
  bool _isInitialized = false;

  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _attach(widget.controller);
  }

  @override
  void didUpdateWidget(covariant ShortVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller);
      _resetUiState();
      _attach(widget.controller);
    }
  }

  @override
  void dispose() {
    _detach(_controller);
    super.dispose();
  }

  void _resetUiState() {
    _isPlaying = false;
    _isBuffering = true;
    _isInitialized = false;
  }

  void _attach(VideoPlayerController? controller) {
    if (controller == null) return;

    _controller = controller;
    controller.addListener(_videoListener);

    _updateState(); // initial sync
  }

  void _detach(VideoPlayerController? controller) {
    controller?.removeListener(_videoListener);
  }

  void _videoListener() {
    if (!mounted) return;

    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;

    // 🔥 Only rebuild when something actually changes
    if (_isInitialized != value.isInitialized ||
        _isPlaying != value.isPlaying ||
        _isBuffering != value.isBuffering) {
      setState(() {
        _isInitialized = value.isInitialized;
        _isPlaying = value.isPlaying;
        _isBuffering = value.isBuffering;
      });
    }
  }

  void _updateState() {
    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;

    _isInitialized = value.isInitialized;
    _isPlaying = value.isPlaying;
    _isBuffering = value.isBuffering;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null || !_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 🎥 VIDEO (TikTok-style)
          Container(
            color: Colors.black,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
          ),

          // 🔄 BUFFERING
          if (_isBuffering) const Center(child: CircularProgressIndicator()),

          // ▶️ PLAY ICON
          if (!_isPlaying && !_isBuffering)
            const Center(child: _PlayPauseOverlay()),
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.black, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(Icons.play_arrow, color: colors.white, size: 42),
      ),
    );
  }
}
