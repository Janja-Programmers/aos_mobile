import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/short_session_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/short_video_cache_provider.dart';

/// ─────────────────────────────────────────────
/// PLAYBACK AUTHORITY (PURE DECISION ENGINE)
/// ─────────────────────────────────────────────

final playbackAuthorityProvider = Provider<PlaybackAuthority>((ref) {
  final cache = ref.read(shortVideoCacheProvider.notifier);
  return PlaybackAuthority(cache);
});

/// RULES:
/// ✔ Session = intent only
/// ✔ Authority = decision only
/// ✔ Cache = execution + reactive lifecycle state
///
/// IMPORTANT:
/// - Authority commands the cache through methods.
/// - UI watches cache state separately.
/// - Authority does not create controllers directly.
/// - Authority does not render or mutate widgets.
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
    if (next.status == SessionStatus.inactive) {
      debugPrint("🛑 Authority → inactive → clear cache");
      await _cache.clear();
      return;
    }

    if (next.status == SessionStatus.paused) {
      await _issuePauseAllCommand();
      return;
    }

    final index = next.activeIndex;

    if (index < 0 || index >= urls.length) return;

    debugPrint("🧠 Authority → index=$index status=${next.status}");

    await _issuePlaybackCommand(
      activeIndex: index,
      urls: urls,
      direction: next.scrollDirection,
    );
  }

  /// ─────────────────────────────────────────────
  /// DECISION → COMMAND TRANSLATION
  /// ─────────────────────────────────────────────

  Future<void> _issuePlaybackCommand({
    required int activeIndex,
    required List<String> urls,
    required ScrollDirection direction,
  }) async {
    final validIndexes = <int>{};

    /// Window rule:
    /// keep active video + immediate previous + immediate next.
    ///
    /// This keeps memory controlled while making vertical swipes feel instant.
    validIndexes.add(activeIndex);

    if (activeIndex - 1 >= 0) validIndexes.add(activeIndex - 1);
    if (activeIndex + 1 < urls.length) validIndexes.add(activeIndex + 1);

    debugPrint(
      "🪟 Authority window → active=$activeIndex valid=$validIndexes direction=$direction",
    );

    /// Cleanup first so removed controllers cannot keep playing.
    _cache.disposeOutsideWindow(validIndexes);

    /// Prepare all controllers inside the active preload window.
    ///
    /// Cache emits:
    /// initializing → ready/error
    ///
    /// ShortVideoView reacts to that state by rebuilding itself.
    await Future.wait(
      validIndexes.map((i) => _cache.ensureController(i, urls[i])),
    );

    /// Playback command remains centralized here.
    /// UI never calls controller.play() directly.
    await _cache.play(activeIndex);
  }

  /// ─────────────────────────────────────────────
  /// PAUSE COMMAND
  /// ─────────────────────────────────────────────

  Future<void> _issuePauseAllCommand() async {
    await _cache.pauseAll();
  }

  /// ─────────────────────────────────────────────
  /// TAP INTENT (NO UI MUTATION, NO CONTROLLER CREATION)
  /// ─────────────────────────────────────────────

  Future<void> togglePlayPause(int activeIndex) async {
    debugPrint("👆 Authority toggle → index=$activeIndex");

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
    debugPrint("⏸ Authority → pauseAll");
    await _cache.pauseAll();
  }

  Future<void> onResume({
    required int activeIndex,
    required List<String> urls,
  }) async {
    debugPrint("▶️ Authority → resume index=$activeIndex");

    await _issuePlaybackCommand(
      activeIndex: activeIndex,
      urls: urls,
      direction: ScrollDirection.idle,
    );
  }
}
