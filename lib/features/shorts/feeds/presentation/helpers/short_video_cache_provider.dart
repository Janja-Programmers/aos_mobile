import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// ─────────────────────────────────────────────
/// VIDEO CACHE PROVIDER
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// → Manage VideoPlayerController lifecycle
/// → Maintain preload window
/// → Guarantee deterministic playback
///

final shortVideoCacheProvider = Provider<ShortVideoCacheManager>((ref) {
  final manager = ShortVideoCacheManager();

  ref.onDispose(manager.dispose);

  return manager;
});

/// ─────────────────────────────────────────────
/// VIDEO CACHE MANAGER
/// ─────────────────────────────────────────────

class ShortVideoCacheManager {
  /// Active controllers
  final Map<int, VideoPlayerController> _controllers = {};

  /// Prevent duplicate initialization
  final Set<int> _initializing = {};

  /// Playback window radius
  static const int _windowRadius = 1;

  /// ─────────────────────────────────────────────
  /// PUBLIC API
  /// ─────────────────────────────────────────────

  Future<void> updateWindow({
    required int activeIndex,
    required List<String> urls,
    bool muted = false,
  }) async {
    final min = activeIndex - _windowRadius;
    final max = activeIndex + _windowRadius;

    // Create required controllers
    for (int i = min; i <= max; i++) {
      if (i < 0 || i >= urls.length) continue;

      await _ensureController(i, urls[i]);
    }

    // Playback logic
    for (final entry in _controllers.entries) {
      final index = entry.key;
      final controller = entry.value;

      if (index == activeIndex) {
        await _play(controller, muted);
      } else {
        await _pause(controller);
      }
    }

    // Cleanup distant controllers
    _cleanup(min, max);
  }

  VideoPlayerController? controllerFor(int index) {
    return _controllers[index];
  }

  /// ─────────────────────────────────────────────
  /// INTERNAL: CREATE
  /// ─────────────────────────────────────────────

  Future<void> _ensureController(int index, String url) async {
    if (_controllers.containsKey(index)) return;

    if (_initializing.contains(index)) return;

    _initializing.add(index);

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await controller.initialize();

      await controller.setLooping(true);

      _controllers[index] = controller;
    } catch (_) {
      await controller.dispose();
    } finally {
      _initializing.remove(index);
    }
  }

  /// ─────────────────────────────────────────────
  /// INTERNAL: PLAY
  /// ─────────────────────────────────────────────

  Future<void> _play(VideoPlayerController controller, bool muted) async {
    if (!controller.value.isInitialized) return;

    await controller.setVolume(muted ? 0.0 : 1.0);

    if (!controller.value.isPlaying) {
      await controller.play();
    }
  }

  /// ─────────────────────────────────────────────
  /// INTERNAL: PAUSE
  /// ─────────────────────────────────────────────

  Future<void> _pause(VideoPlayerController controller) async {
    if (controller.value.isPlaying) {
      await controller.pause();
    }
  }

  /// ─────────────────────────────────────────────
  /// INTERNAL: CLEANUP
  /// ─────────────────────────────────────────────

  void _cleanup(int min, int max) {
    final keys = _controllers.keys.toList();

    for (final k in keys) {
      if (k < min || k > max) {
        _controllers[k]?.dispose();
        _controllers.remove(k);
      }
    }
  }

  /// ─────────────────────────────────────────────
  /// GLOBAL PAUSE
  /// ─────────────────────────────────────────────

  Future<void> pauseAll() async {
    for (final c in _controllers.values) {
      if (c.value.isPlaying) {
        await c.pause();
      }
    }
  }

  /// ─────────────────────────────────────────────
  /// DISPOSE
  /// ─────────────────────────────────────────────

  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }

    _controllers.clear();
    _initializing.clear();
  }
}
