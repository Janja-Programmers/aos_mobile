import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/short_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_tracking_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:video_player/video_player.dart';

class ShortsController extends StateNotifier<ShortsState> {
  final ShortsTrackingApi trackingApi;
  final ShortsEngagementApi engagementApi;
  final ShortsRepository repository;

  ShortsController(this.repository, this.trackingApi, this.engagementApi)
    : super(const ShortsState(shorts: []));

  // ───────────── INTERNAL STATE ─────────────

  final Map<int, VideoPlayerController> _players = {};

  bool _isInitializing = false;
  bool _isLoadingMore = false;

  Timer? _flushTimer;

  // ───────────── TRACKING STATE ─────────────

  final Set<String> _impressionsSent = {};
  final Set<String> _viewsSent = {};

  final Set<String> _pendingImpressions = {};
  final Set<String> _pendingViews = {};

  final Map<String, DateTime> _viewTimers = {};

  static const Duration _flushInterval = Duration(seconds: 3);
  static const Duration _viewThreshold = Duration(seconds: 2);

  // ───────────── INIT ─────────────

  Future<void> loadInitial() async {
    if (_isInitializing) return;

    _isInitializing = true;

    _startTrackingLoop();

    state = state.copyWith(isLoading: true);

    try {
      final page = await repository.fetchForYou();

      state = state.copyWith(
        shorts: page.items,
        cursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoading: false,
        currentIndex: 0,
      );

      _initFirstPlayer();
    } catch (e) {
      appLogger.i('❌ API ERROR: $e');

      state = state.copyWith(isLoading: false);
    } finally {
      _isInitializing = false;
    }
  }

  // ───────────── PAGINATION ─────────────

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasMore || state.cursor == null) return;

    _isLoadingMore = true;

    try {
      final page = await repository.fetchForYou(cursor: state.cursor);

      final byId = <String, Short>{
        for (final item in state.shorts) item.id.value: item,
      };
      for (final item in page.items) {
        byId[item.id.value] = item;
      }

      state = state.copyWith(
        shorts: List.unmodifiable(byId.values),
        cursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    } catch (e) {
      appLogger.i('❌ LOAD MORE ERROR: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  // ───────────── PLAYER ─────────────

  VideoPlayerController _createPlayer(String url) {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    controller.initialize().then((_) {
      controller.setLooping(true);
    });

    return controller;
  }

  void _initFirstPlayer() {
    if (state.shorts.isEmpty) return;

    final first = state.shorts[0];

    _players[0] = _createPlayer(first.playbackUrl);

    _trackImpression(first.id.value);
    _startViewTimer(first.id.value);
  }

  // ───────────── SCROLL ─────────────

  void onPageChanged(int index) {
    if (index < 0 || index >= state.shorts.length) return;

    final previousIndex = state.currentIndex;

    if (previousIndex < state.shorts.length) {
      _stopViewTimer(state.shorts[previousIndex].id.value);
    }

    state = state.copyWith(currentIndex: index);

    // 🛑 Pause ALL players
    for (final p in _players.values) {
      p.pause();
      p.setVolume(0.0);
    }

    // 🎯 Current video
    _players[index] ??= _createPlayer(state.shorts[index].playbackUrl);

    final current = _players[index];
    if (current != null && current.value.isInitialized) {
      current.setVolume(.5);
      current.play();
    }

    // ⚡ Preload next (silent)
    final next = index + 1;
    if (next < state.shorts.length) {
      _players[next] ??= _createPlayer(state.shorts[next].playbackUrl);
      _players[next]?.setVolume(0.0);
    }

    _cleanup(index);

    final short = state.shorts[index];

    _trackImpression(short.id.value);
    _startViewTimer(short.id.value);

    if (index >= state.shorts.length - 2) {
      loadMore();
    }
  }

  // ───────────── CLEANUP ─────────────

  void _cleanup(int index) {
    final keys = _players.keys.toList();

    for (final k in keys) {
      if (k < index - 1 || k > index + 1) {
        _players[k]?.dispose();
        _players.remove(k);
      }
    }
  }

  // ───────────── TRACKING ─────────────

  void _startTrackingLoop() {
    if (_flushTimer != null) return;

    _flushTimer = Timer.periodic(_flushInterval, (_) => _flushTracking());
  }

  void _trackImpression(String id) {
    if (_impressionsSent.contains(id)) return;
    _pendingImpressions.add(id);
  }

  void _startViewTimer(String id) {
    if (_viewsSent.contains(id)) return;
    _viewTimers[id] = DateTime.now();
  }

  void _stopViewTimer(String id) {
    final start = _viewTimers[id];
    if (start == null) return;

    final duration = DateTime.now().difference(start);

    if (duration >= _viewThreshold) {
      _pendingViews.add(id);
    }

    _viewTimers.remove(id);
  }

  Future<void> _flushTracking() async {
    final impressions = _pendingImpressions.difference(_impressionsSent);
    final views = _pendingViews.difference(_viewsSent);

    _pendingImpressions.clear();
    _pendingViews.clear();

    if (impressions.isNotEmpty) {
      await Future.wait(
        impressions.map((id) => trackingApi.trackImpression(shortId: id)),
      );
      _impressionsSent.addAll(impressions);
    }

    if (views.isNotEmpty) {
      await Future.wait(
        views.map(
          (id) => trackingApi.trackView(
            shortId: id,
            watchMs: _viewThreshold.inMilliseconds,
          ),
        ),
      );
      _viewsSent.addAll(views);
    }
  }

  // ───────────── METRICS / ENGAGEMENT ─────────────

  Future<void> toggleLike(String shortId) async {
    final index = state.shorts.indexWhere((s) => s.id.value == shortId);
    if (index == -1) return;

    final originalShort = state.shorts[index];
    final wasLiked = originalShort.isLiked;

    final optimisticShort = originalShort.copyWith(
      metrics: originalShort.metrics.copyWith(
        likeCount: wasLiked
            ? (originalShort.metrics.likeCount - 1).clamp(0, 1 << 31)
            : originalShort.metrics.likeCount + 1,
      ),
      viewerState: originalShort.viewerState.copyWith(liked: !wasLiked),
    );

    _replaceShortAt(index, optimisticShort);

    final result = await engagementApi.toggleLike(shortId: shortId);

    result.fold(
      (failure) {
        appLogger.e('❌ TOGGLE LIKE FAILED', error: failure);

        // Roll back to the exact previous short.
        final rollbackIndex = state.shorts.indexWhere(
          (s) => s.id.value == shortId,
        );

        if (rollbackIndex == -1) return;

        _replaceShortAt(rollbackIndex, originalShort);
      },
      (toggleResult) {
        appLogger.i('✅ LIKE SYNCED');

        final syncIndex = state.shorts.indexWhere(
          (s) => s.id.value == toggleResult.shortId,
        );

        if (syncIndex == -1) return;

        final currentShort = state.shorts[syncIndex];
        final currentlyLiked = currentShort.isLiked;

        var correctedLikeCount = currentShort.metrics.likeCount;

        // Usually this will not run because optimistic state already matches backend.
        // It protects us if backend returns the opposite final state.
        if (toggleResult.liked != currentlyLiked) {
          correctedLikeCount = toggleResult.liked
              ? currentShort.metrics.likeCount + 1
              : (currentShort.metrics.likeCount - 1).clamp(0, 1 << 31);
        }

        final syncedShort = currentShort.copyWith(
          metrics: currentShort.metrics.copyWith(likeCount: correctedLikeCount),
          viewerState: currentShort.viewerState.copyWith(
            liked: toggleResult.liked,
          ),
        );

        _replaceShortAt(syncIndex, syncedShort);
      },
    );
  }

  void _replaceShortAt(int index, Short updatedShort) {
    if (index < 0 || index >= state.shorts.length) return;

    final updatedList = [...state.shorts];
    updatedList[index] = updatedShort;

    state = state.copyWith(shorts: updatedList);
  }

  void incrementCommentCount(int index) {
    if (index < 0 || index >= state.shorts.length) return;

    final short = state.shorts[index];

    final updated = short.copyWith(
      metrics: short.metrics.copyWith(
        commentCount: short.metrics.commentCount + 1,
      ),
    );

    final newList = [...state.shorts];
    newList[index] = updated;

    state = state.copyWith(shorts: newList);
  }

  // ───────────── ACCESS ─────────────

  VideoPlayerController? getPlayer(int index) => _players[index];

  // ───────────── DISPOSE ─────────────

  @override
  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }

    _flushTimer?.cancel();

    super.dispose();
  }
}
