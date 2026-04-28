import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_video_controller_state.dart';

/// ─────────────────────────────────────────────
/// VIDEO CACHE PROVIDER
/// ─────────────────────────────────────────────

final shortVideoCacheProvider =
    StateNotifierProvider<
      ShortVideoCacheManager,
      Map<int, ShortVideoControllerState>
    >((ref) {
      final manager = ShortVideoCacheManager();
      ref.onDispose(manager.dispose);
      return manager;
    });

final shortVideoControllerStateProvider =
    Provider.family<ShortVideoControllerState?, int>((ref, index) {
      final cacheState = ref.watch(shortVideoCacheProvider);
      return cacheState[index];
    });

/// ─────────────────────────────────────────────
/// CACHE MANAGER (EXECUTION ONLY)
/// ─────────────────────────────────────────────
///
/// RESPONSIBILITY:
/// ✔ Create controllers
/// ✔ Store controller state (reactive)
/// ✔ Dispose controllers
/// ✔ Execute play/pause commands
///
/// DOES NOT:
/// ❌ decide active index
/// ❌ compute preload windows
/// ❌ interpret scroll direction
/// ❌ enforce playback rules
///

class ShortVideoCacheManager
    extends StateNotifier<Map<int, ShortVideoControllerState>> {
  ShortVideoCacheManager() : super(const {});

  bool _isDisposed = false;
  int _generation = 0;

  /// ─────────────────────────────────────────────
  /// CREATE / ENSURE
  /// ─────────────────────────────────────────────
  Future<void> ensureController(int index, String url) async {
    if (_isDisposed) return;

    final generation = _generation;
    final existing = state[index];

    /// Already ready → skip
    if (existing?.isReady == true) {
      debugPrint("♻️ Skip ensure → already ready → index=$index");
      return;
    }

    /// Already initializing → skip
    if (existing?.isInitializing == true) {
      debugPrint("⏳ Skip ensure → already initializing → index=$index");
      return;
    }

    /// Emit initializing state
    state = {
      ...state,
      index: ShortVideoControllerState(
        index: index,
        isInitializing: true,
        isReady: false,
      ),
    };

    debugPrint("🎬 Controller initializing → index=$index url=$url");

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await controller.initialize().timeout(const Duration(seconds: 10));
      if (_isDisposed || generation != _generation) {
        await controller.dispose();
        debugPrint("🛑 Controller discarded after stale init → index=$index");
        return;
      }

      await controller.setLooping(true);
      if (_isDisposed || generation != _generation) {
        await controller.dispose();
        debugPrint("🛑 Controller discarded after stale init → index=$index");
        return;
      }

      /// Emit ready state
      state = {
        ...state,
        index: ShortVideoControllerState(
          index: index,
          controller: controller,
          isInitializing: false,
          isReady: true,
        ),
      };

      debugPrint(
        "📦 Controller ready → index=$index duration=${controller.value.duration}",
      );
    } catch (e) {
      appLogger.e("❌ Controller init failed → index=$index | $e");

      try {
        await controller.dispose();
      } catch (_) {}

      /// Emit error state
      state = {
        ...state,
        index: ShortVideoControllerState(
          index: index,
          isInitializing: false,
          isReady: false,
          error: e,
        ),
      };
    }
  }

  /// ─────────────────────────────────────────────
  /// EXECUTION COMMANDS (FROM AUTHORITY ONLY)
  /// ─────────────────────────────────────────────

  Future<void> play(int index, {bool muted = false}) async {
    if (_isDisposed) return;

    final controller = state[index]?.controller;

    if (controller == null || !controller.value.isInitialized) return;

    await controller.setVolume(muted ? 0 : 1);

    if (!controller.value.isPlaying) {
      await controller.play();
      debugPrint("▶️ Controller play → index=$index");
    }
  }

  Future<void> pause(int index) async {
    final controller = state[index]?.controller;

    if (controller == null) return;

    if (controller.value.isPlaying) {
      await controller.pause();
      debugPrint("⏸ Controller pause → index=$index");
    }
  }

  Future<void> pauseAll() async {
    for (final entry in state.entries) {
      final controller = entry.value.controller;

      if (controller != null && controller.value.isPlaying) {
        await controller.pause();
        debugPrint("⏸ Controller pauseAll → index=${entry.key}");
      }
    }
  }

  /// ─────────────────────────────────────────────
  /// CLEANUP (PURE MEMORY MANAGEMENT)
  /// ─────────────────────────────────────────────

  void disposeOutsideWindow(Set<int> validIndexes) {
    final nextState = Map<int, ShortVideoControllerState>.from(state);

    for (final entry in state.entries) {
      final index = entry.key;

      if (!validIndexes.contains(index)) {
        try {
          entry.value.controller?.dispose();
          debugPrint("🧹 Controller disposed → index=$index");
        } catch (_) {}

        nextState.remove(index);
      }
    }

    state = nextState;
  }

  Future<void> clear() async {
    _generation++;

    for (final entry in state.entries) {
      try {
        await entry.value.controller?.pause();
        await entry.value.controller?.dispose();
        debugPrint("🧹 Controller cleared → index=${entry.key}");
      } catch (_) {}
    }

    state = const {};
  }

  @override
  void dispose() {
    _isDisposed = true;
    _generation++;

    for (final entry in state.entries) {
      try {
        entry.value.controller?.dispose();
      } catch (_) {}
    }

    super.dispose();
  }

  /// ─────────────────────────────────────────────
  /// ACCESSOR
  /// ─────────────────────────────────────────────

  VideoPlayerController? controllerFor(int index) {
    return state[index]?.controller;
  }
}
