import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// ─────────────────────────────────────────────
/// VIDEO CACHE PROVIDER
/// ─────────────────────────────────────────────

final shortVideoCacheProvider = Provider<ShortVideoCacheManager>((ref) {
  final manager = ShortVideoCacheManager();

  ref.onDispose(manager.dispose);

  return manager;
});

/// ─────────────────────────────────────────────
/// CACHE MANAGER (EXECUTION ONLY)
/// ─────────────────────────────────────────────
///
/// RESPONSIBILITY:
/// ✔ Create controllers
/// ✔ Store controllers
/// ✔ Dispose controllers
/// ✔ Execute play/pause commands
///
/// DOES NOT:
/// ❌ decide active index
/// ❌ compute preload windows
/// ❌ interpret scroll direction
/// ❌ enforce playback rules
///

class ShortVideoCacheManager {
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _initializing = {};

  /// ─────────────────────────────────────────────
  /// CREATE / ENSURE
  /// ─────────────────────────────────────────────

  Future<void> ensureController(int index, String url) async {
    if (_controllers.containsKey(index)) return;
    if (_initializing.contains(index)) return;

    _initializing.add(index);

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await controller.initialize().timeout(const Duration(seconds: 10));
      await controller.setLooping(true);

      _controllers[index] = controller;

      appLogger.i("📦 Controller ready → index=$index");
    } catch (e) {
      appLogger.e("❌ Controller init failed → index=$index | $e");
      try {
        await controller.dispose();
      } catch (_) {}
    } finally {
      _initializing.remove(index);
    }
  }

  /// ─────────────────────────────────────────────
  /// EXECUTION COMMANDS (FROM AUTHORITY ONLY)
  /// ─────────────────────────────────────────────

  Future<void> play(int index, {bool muted = false}) async {
    final controller = _controllers[index];
    if (controller == null || !controller.value.isInitialized) return;

    await controller.setVolume(muted ? 0 : 1);

    if (!controller.value.isPlaying) {
      await controller.play();
    }
  }

  Future<void> pause(int index) async {
    final controller = _controllers[index];
    if (controller == null) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    }
  }

  Future<void> pauseAll() async {
    for (final c in _controllers.values) {
      if (c.value.isPlaying) {
        await c.pause();
      }
    }
  }

  /// ─────────────────────────────────────────────
  /// CLEANUP (PURE MEMORY MANAGEMENT)
  /// ─────────────────────────────────────────────

  void disposeOutsideWindow(Set<int> validIndexes) {
    final keys = _controllers.keys.toList();

    for (final k in keys) {
      if (!validIndexes.contains(k)) {
        try {
          _controllers[k]?.dispose();
        } catch (_) {}

        _controllers.remove(k);
      }
    }
  }

  Future<void> clear() async {
    for (final c in _controllers.values) {
      try {
        await c.pause();
        await c.dispose();
      } catch (_) {}
    }

    _controllers.clear();
    _initializing.clear();
  }

  void dispose() {
    for (final c in _controllers.values) {
      try {
        c.dispose();
      } catch (_) {}
    }

    _controllers.clear();
    _initializing.clear();
  }

  /// ─────────────────────────────────────────────
  /// ACCESSOR
  /// ─────────────────────────────────────────────

  VideoPlayerController? controllerFor(int index) {
    return _controllers[index];
  }
}
