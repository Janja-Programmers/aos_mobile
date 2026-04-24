import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/rendering.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/short_session_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/short_video_cache_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ─────────────────────────────────────────────
/// PLAYBACK AUTHORITY (PURE DECISION ENGINE)
/// ─────────────────────────────────────────────

final playbackAuthorityProvider = Provider<PlaybackAuthority>((ref) {
  final cache = ref.read(shortVideoCacheProvider);
  return PlaybackAuthority(cache);
});

/// RULES:
/// ✔ Session = intent only
/// ✔ Authority = decision only
/// ✔ Cache = execution only
///
/// NO DIRECT CONTROLLER ACCESS HERE
///

class PlaybackAuthority {
  final ShortVideoCacheManager _cache;

  PlaybackAuthority(this._cache);

  /// ─────────────────────────────────────────────
  /// SESSION → DECISION → COMMANDS
  /// ─────────────────────────────────────────────

  Future<void> onSessionChanged({
    required ShortsSessionState prev,
    required ShortsSessionState next,
    required List<String> urls,
  }) async {
    final index = next.activeIndex;

    if (index < 0 || index >= urls.length) return;

    appLogger.i("🧠 Authority → index=$index status=${next.status}");

    if (next.status == SessionStatus.paused) {
      _issuePauseAllCommand();
      return;
    }

    _issuePlaybackCommand(
      activeIndex: index,
      urls: urls,
      direction: next.scrollDirection,
    );
  }

  /// ─────────────────────────────────────────────
  /// DECISION → COMMAND TRANSLATION
  /// ─────────────────────────────────────────────

  void _issuePlaybackCommand({
    required int activeIndex,
    required List<String> urls,
    required ScrollDirection direction,
  }) {
    final validIndexes = <int>{};

    // simple deterministic window rule (no “logic ownership”)
    validIndexes.add(activeIndex);

    if (activeIndex - 1 >= 0) validIndexes.add(activeIndex - 1);
    if (activeIndex + 1 < urls.length) validIndexes.add(activeIndex + 1);

    /// EXECUTION LAYER ONLY
    _cache.disposeOutsideWindow(validIndexes);

    for (final i in validIndexes) {
      _cache.ensureController(i, urls[i]);
    }

    _cache.play(activeIndex);
  }

  /// ─────────────────────────────────────────────
  /// PAUSE COMMAND
  /// ─────────────────────────────────────────────

  void _issuePauseAllCommand() {
    _cache.pauseAll();
  }

  /// ─────────────────────────────────────────────
  /// TAP INTENT (NO STATE, NO CONTROLLER ACCESS)
  /// ─────────────────────────────────────────────

  Future<void> togglePlayPause(int activeIndex) async {
    appLogger.i("👆 Authority toggle → index=$activeIndex");

    final controller = _cache.controllerFor(activeIndex);

    if (controller == null || !controller.value.isInitialized) return;

    final isPlaying = controller.value.isPlaying;

    if (isPlaying) {
      await _cache.pause(activeIndex);
    } else {
      await _cache.pauseAll();
      await _cache.play(activeIndex);
    }
  }

  /// ─────────────────────────────────────────────
  /// LIFECYCLE EVENTS
  /// ─────────────────────────────────────────────

  Future<void> onPause() async {
    appLogger.i("⏸ Authority → pauseAll");
    await _cache.pauseAll();
  }

  Future<void> onResume({
    required int activeIndex,
    required List<String> urls,
  }) async {
    appLogger.i("▶️ Authority → resume index=$activeIndex");

    _issuePlaybackCommand(
      activeIndex: activeIndex,
      urls: urls,
      direction: ScrollDirection.idle,
    );
  }
}
