import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:africaonlinestores/features/shorts/application/utils/feed_window.dart';

typedef FeedWindowCallback = void Function(FeedWindow window);

class FeedCoordinator {
  final PageController pageController;

  final int totalCount;

  /// How many items to keep alive (current ± range)
  final int keepAliveRadius;

  /// How many items to preload beyond keepAlive
  final int preloadRadius;

  FeedWindowCallback? onWindowChanged;

  double _lastPage = 0;
  int _currentIndex = 0;

  StreamSubscription? _ticker;

  FeedCoordinator({
    required this.pageController,
    required this.totalCount,
    this.keepAliveRadius = 1,
    this.preloadRadius = 2,
  });

  // ───────────── START LISTENING ─────────────

  void start() {
    pageController.addListener(_onScroll);
  }

  void dispose() {
    pageController.removeListener(_onScroll);
    _ticker?.cancel();
  }

  // ───────────── SCROLL HANDLER ─────────────

  void _onScroll() {
    final page = pageController.page;

    if (page == null) return;

    final newIndex = page.round();

    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      _emitWindow(page);
    }

    _lastPage = page;
  }

  // ───────────── CORE LOGIC ─────────────

  void _emitWindow(double page) {
    final direction = page - _lastPage;

    final isScrollingForward = direction > 0;

    final active = _currentIndex;

    final keepAlive = <int>{};
    final preload = <int>{};

    // ───────── KEEP ALIVE WINDOW ─────────

    for (int i = -keepAliveRadius; i <= keepAliveRadius; i++) {
      final index = active + i;
      if (_isValid(index)) {
        keepAlive.add(index);
      }
    }

    // ───────── PRELOAD WINDOW ─────────

    final start = isScrollingForward ? 1 : -preloadRadius;
    final end = isScrollingForward ? preloadRadius : -1;

    for (
      int i = start;
      isScrollingForward ? i <= end : i >= end;
      i += isScrollingForward ? 1 : -1
    ) {
      final index = active + i;
      if (_isValid(index) && !keepAlive.contains(index)) {
        preload.add(index);
      }
    }

    // ───────── DISPOSE WINDOW ─────────

    final dispose = <int>{};

    for (int i = 0; i < totalCount; i++) {
      if (!keepAlive.contains(i) && !preload.contains(i)) {
        dispose.add(i);
      }
    }

    onWindowChanged?.call(
      FeedWindow(
        activeIndex: active,
        keepAlive: keepAlive,
        preload: preload,
        dispose: dispose,
      ),
    );
  }

  // ───────────── HELPERS ─────────────

  bool _isValid(int index) {
    return index >= 0 && index < totalCount;
  }
}
