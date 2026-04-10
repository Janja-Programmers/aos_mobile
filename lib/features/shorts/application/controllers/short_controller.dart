import 'dart:async';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/features/shorts/application/state/short_state.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_tracking_api.dart';

class ShortsController extends StateNotifier<ShortsState> {
  final ShortsFeedApi feedApi;
  final ShortsTrackingApi trackingApi;
  final ShortsEngagementApi engagementApi;

  ShortsController(this.feedApi, this.trackingApi, this.engagementApi)
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

    final res = await feedApi.fetchForYou();

    res.fold(
      (err) {
        appLogger.i("❌ API ERROR: $err");

        state = state.copyWith(isLoading: false);
      },
      (page) {
        state = state.copyWith(
          shorts: page.items,
          cursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoading: false,
          currentIndex: 0,
        );

        _initFirstPlayer();
      },
    );

    _isInitializing = false;
  }
  // ───────────── PAGINATION ─────────────

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasMore || state.cursor == null) return;

    _isLoadingMore = true;

    final res = await feedApi.fetchForYou(cursor: state.cursor);

    res.fold((_) {}, (page) {
      state = state.copyWith(
        shorts: [...state.shorts, ...page.items],
        cursor: page.nextCursor,
        hasMore: page.hasMore,
      );
    });

    _isLoadingMore = false;
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
    for (final id in _pendingImpressions) {
      await trackingApi.trackImpression(shortId: id);
      _impressionsSent.add(id);
    }
    _pendingImpressions.clear();

    for (final id in _pendingViews) {
      await trackingApi.trackView(shortId: id);
      _viewsSent.add(id);
    }
    _pendingViews.clear();
  }

  // ───────────── METRICS ─────────────
  Future<void> toggleLike(String shortId) async {
    // 🔒 Find the short safely by ID
    final short = state.shorts.firstWhere(
      (s) => s.id.value == shortId,
      orElse: () => throw Exception("Short not found"),
    );

    final current = short.metrics;

    // 🔥 OPTIMISTIC UPDATE
    final optimisticMetrics = current.copyWith(
      likedByMe: !current.likedByMe,
      likeCount: current.likedByMe
          ? (current.likeCount - 1).clamp(0, 1 << 31)
          : current.likeCount + 1,
    );

    _updateShortById(shortId, optimisticMetrics);

    // 🔥 API CALL
    final res = await engagementApi.toggleLike(shortId: shortId);

    res.fold(
      (e) {
        appLogger.e('❌ TOGGLE LIKE FAILED', error: e);

        // 🔥 ROLLBACK
        _updateShortById(shortId, current);
      },
      (serverMetrics) {
        appLogger.i('✅ LIKE SYNCED');

        // 🔥 FINAL SYNC (source of truth)
        _updateShortById(shortId, serverMetrics);
      },
    );
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

  void _updateShortById(String shortId, dynamic newMetrics) {
    final updatedList = state.shorts.map((s) {
      if (s.id.value == shortId) {
        return s.copyWith(metrics: newMetrics);
      }
      return s;
    }).toList();

    state = state.copyWith(shorts: updatedList);
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
