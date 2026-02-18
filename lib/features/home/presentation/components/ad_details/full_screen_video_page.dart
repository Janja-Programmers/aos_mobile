import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideoPage extends StatefulWidget {
  const FullscreenVideoPage({
    super.key,
    required this.videoPath,
    this.thumbnailPath,
  });

  final String videoPath;
  final String? thumbnailPath;

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  VideoPlayerController? _vc;
  Future<void>? _init;
  String? _error;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = widget.videoPath.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Video URL is missing.');
      return;
    }

    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      _vc = c;

      _init = c.initialize().then((_) async {
        if (!mounted) return;
        await c.play();
        setState(() {});
      });

      setState(() {});
      await _init;
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load video: $e');
    }
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final vc = _vc;
    if (vc == null || !vc.value.isInitialized) return;

    vc.value.isPlaying ? vc.pause() : vc.play();
    setState(() {});
  }

  void _toggleMute() {
    final vc = _vc;
    if (vc == null || !vc.value.isInitialized) return;

    _muted = !_muted;
    vc.setVolume(_muted ? 0.0 : 1.0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vc = _vc;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Stack(
                children: [
                  Center(
                    child: (vc == null || _init == null)
                        ? const CircularProgressIndicator()
                        : FutureBuilder<void>(
                            future: _init,
                            builder: (context, snap) {
                              if (snap.connectionState !=
                                      ConnectionState.done ||
                                  !vc.value.isInitialized) {
                                return const CircularProgressIndicator();
                              }
                              return AspectRatio(
                                aspectRatio: vc.value.aspectRatio == 0
                                    ? 16 / 9
                                    : vc.value.aspectRatio,
                                child: VideoPlayer(vc),
                              );
                            },
                          ),
                  ),

                  if (vc != null && vc.value.isInitialized)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _togglePlay,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              vc.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 54,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (vc != null && vc.value.isInitialized)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Slider(
                              value: vc.value.position.inMilliseconds
                                  .clamp(0, vc.value.duration.inMilliseconds)
                                  .toDouble(),
                              min: 0,
                              max: (vc.value.duration.inMilliseconds == 0)
                                  ? 1
                                  : vc.value.duration.inMilliseconds.toDouble(),
                              onChanged: (v) =>
                                  vc.seekTo(Duration(milliseconds: v.round())),
                            ),
                            Row(
                              children: [
                                const Spacer(),
                                IconButton(
                                  onPressed: _toggleMute,
                                  icon: Icon(
                                    _muted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
