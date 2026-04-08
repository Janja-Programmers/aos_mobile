import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/features/shorts/application/utils/feed_window.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/features/shorts/application/utils/controller_entry.dart';

class ControllerPool {
  final Map<int, ControllerEntry> _entries = {};

  /// Limit concurrent inits (VERY IMPORTANT)
  final int maxConcurrentInitializations;

  int _currentInitializations = 0;

  final Queue<int> _initQueue = Queue();

  ControllerPool({this.maxConcurrentInitializations = 2});

  // ───────────── PUBLIC API ─────────────

  ControllerEntry? get(int index) => _entries[index];

  void handleWindow({required FeedWindow window, required List<String> urls}) {
    _prepare(window, urls);
    _dispose(window);
  }

  // ───────────── PREPARE ─────────────

  void _prepare(FeedWindow window, List<String> urls) {
    final targets = {...window.keepAlive, ...window.preload};

    for (final index in targets) {
      if (_entries.containsKey(index)) continue;

      final url = urls[index];

      _initQueue.add(index);
      _processQueue(urls);
    }
  }

  void _processQueue(List<String> urls) {
    if (_currentInitializations >= maxConcurrentInitializations) return;
    if (_initQueue.isEmpty) return;

    final index = _initQueue.removeFirst();

    final url = urls[index];

    _initialize(index, url).whenComplete(() {
      _currentInitializations--;
      _processQueue(urls);
    });
  }

  Future<void> _initialize(int index, String url) async {
    _currentInitializations++;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));

      _entries[index] = ControllerEntry(
        index: index,
        url: url,
        controller: controller,
        status: ControllerStatus.initializing,
      );

      await controller.initialize();

      _entries[index] = _entries[index]!.copyWith(
        status: ControllerStatus.ready,
      );
    } catch (_) {
      _entries.remove(index);
    }
  }

  // ───────────── DISPOSE ─────────────

  void _dispose(FeedWindow window) {
    for (final index in window.dispose) {
      final entry = _entries[index];
      if (entry == null) continue;

      entry.controller.dispose();
      _entries.remove(index);
    }
  }

  // ───────────── CONTROL ─────────────

  void play(int index) {
    final entry = _entries[index];
    if (entry == null) return;

    entry.controller.play();
    _entries[index] = entry.copyWith(status: ControllerStatus.playing);
  }

  void pause(int index) {
    final entry = _entries[index];
    if (entry == null) return;

    entry.controller.pause();
    _entries[index] = entry.copyWith(status: ControllerStatus.paused);
  }

  void pauseAllExcept(int index) {
    for (final entry in _entries.values) {
      if (entry.index != index) {
        entry.controller.pause();
      }
    }
  }

  void disposeAll() {
    for (final entry in _entries.values) {
      entry.controller.dispose();
    }
    _entries.clear();
  }
}
