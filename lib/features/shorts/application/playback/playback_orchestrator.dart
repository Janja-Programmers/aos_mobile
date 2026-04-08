import 'package:africaonlinestores/features/shorts/application/playback/controller_pool.dart';
import 'package:africaonlinestores/features/shorts/application/utils/controller_entry.dart';
import 'package:africaonlinestores/features/shorts/application/utils/feed_window.dart';

class PlaybackOrchestrator {
  final ControllerPool _pool;

  int? _currentActiveIndex;

  PlaybackOrchestrator(this._pool);

  // ───────────── ENTRY POINT ─────────────

  void handleWindow(FeedWindow window) {
    final newActive = window.activeIndex;

    // If same index → no-op
    if (_currentActiveIndex == newActive) return;

    final previous = _currentActiveIndex;
    _currentActiveIndex = newActive;

    _pausePrevious(previous);
    _playActive(newActive);
  }

  // ───────────── PLAY ACTIVE ─────────────

  void _playActive(int index) {
    final entry = _pool.get(index);

    if (entry == null) return;

    // If already ready → play immediately
    if (entry.status == ControllerStatus.ready ||
        entry.status == ControllerStatus.paused) {
      _pool.play(index);
      return;
    }

    // If still initializing → wait until ready
    _waitUntilReadyAndPlay(index);
  }

  // ───────────── WAIT FOR READY ─────────────

  Future<void> _waitUntilReadyAndPlay(int index) async {
    const maxAttempts = 20;
    int attempts = 0;

    while (attempts < maxAttempts) {
      final entry = _pool.get(index);

      if (entry == null) return;

      if (entry.status == ControllerStatus.ready) {
        _pool.play(index);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 50));
      attempts++;
    }
  }

  // ───────────── PAUSE PREVIOUS ─────────────

  void _pausePrevious(int? previousIndex) {
    if (previousIndex == null) return;

    _pool.pause(previousIndex);
  }

  // ───────────── GLOBAL CONTROL ─────────────

  void pauseAll() {
    _pool.pauseAllExcept(-1);
    _currentActiveIndex = null;
  }

  void resume() {
    if (_currentActiveIndex != null) {
      _playActive(_currentActiveIndex!);
    }
  }

  int? get activeIndex => _currentActiveIndex;
}
