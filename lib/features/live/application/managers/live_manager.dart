import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/application/state/live_state.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/application/state/room_state_enum.dart';
import 'package:africaonlinestores/features/live/domain/live_bootstrap.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/repository/live_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

class LiveManager extends StateNotifier<LiveState> {
  LiveManager({
    required this.repository,
    required this.mediaService,
    required this.realtimeService,
  }) : super(LiveState.initial()) {
    _mediaSubscription = mediaService.events.listen(_onMediaEvent);
  }

  final LiveRepository repository;
  final LiveMediaService mediaService;
  final RealtimeService realtimeService;

  /// Read-only snapshot for collaborators that coordinate Live domains.
  ///
  /// Mutations remain owned by this manager; callers must use its intent
  /// methods rather than accessing [StateNotifier.state] directly.
  LiveState get currentState => state;

  late final StreamSubscription<MediaTrackEvent> _mediaSubscription;
  final LinkedHashSet<String> _seenReactionIds = LinkedHashSet<String>();
  final LinkedHashMap<String, String> _viewerSessionIds =
      LinkedHashMap<String, String>();

  Future<void> _transitionTail = Future<void>.value();
  int _transitionGeneration = 0;
  bool _startInFlight = false;
  bool _reactionInFlight = false;
  String? _pendingViewerLiveId;
  Future<bool>? _pendingViewerJoin;
  bool _pendingViewerShowUi = false;
  Future<void>? _activeRefresh;

  Future<bool> startLive({
    required String title,
    String? coverImage,
    String? coverMediaId,
    bool micEnabled = true,
    bool cameraEnabled = true,
    bool frontCamera = true,
  }) {
    if (_startInFlight) return Future<bool>.value(false);
    _startInFlight = true;
    final generation = ++_transitionGeneration;
    final transition = _enqueue<bool>(() async {
      if (generation != _transitionGeneration || state.hasActiveRoom) {
        return false;
      }

      _seenReactionIds.clear();
      state = state.copyWith(
        status: LiveStatus.loading,
        clearLive: true,
        clearSession: true,
        clearRole: true,
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
        isPublishing: false,
        isSubscribed: false,
        clearActiveCohostId: true,
        hasLiveUi: false,
        isMicMuted: !micEnabled,
        isCameraEnabled: cameraEnabled,
        isFrontCamera: frontCamera,
        viewerCount: 0,
        reactionTrigger: 0,
        lastReactionType: LiveReactionType.like,
        clearError: true,
      );

      LiveBootstrap bootstrap;
      try {
        bootstrap = await repository.startLive(
          title: title,
          coverImage: coverImage,
          coverMediaId: coverMediaId,
        );
      } on Object catch (error, stackTrace) {
        await _releasePreparedCameraSafely();
        if (!mounted) return false;
        _setFailure('startLive failed', error, stackTrace);
        return false;
      }

      if (!mounted) {
        await _endStartedLiveSafely(bootstrap.live.id);
        return false;
      }
      if (generation != _transitionGeneration) {
        await _endStartedLiveSafely(bootstrap.live.id);
        await _releasePreparedCameraSafely();
        return false;
      }

      _hydrate(bootstrap.live);
      state = state.copyWith(
        session: bootstrap.session,
        role: bootstrap.session.role,
        hasLiveUi: false,
        isMicMuted: !micEnabled,
        isCameraEnabled: cameraEnabled,
        isFrontCamera: frontCamera,
        clearError: true,
      );

      final connected = await _connectSession(
        bootstrap.session,
        generation: generation,
        micEnabled: micEnabled,
        cameraEnabled: cameraEnabled,
        frontCamera: frontCamera,
      );
      if (connected) {
        state = state.copyWith(hasLiveUi: true);
        return true;
      }

      await _endStartedLiveSafely(bootstrap.live.id);
      return false;
    });
    return transition.whenComplete(() => _startInFlight = false);
  }

  Future<bool> joinLive({
    required String liveId,
    bool showLiveUi = true,
    String? sessionId,
  }) {
    final cleanLiveId = liveId.trim();
    final pendingJoin = _pendingViewerJoin;
    if (cleanLiveId.isNotEmpty &&
        _pendingViewerLiveId == cleanLiveId &&
        pendingJoin != null) {
      if (showLiveUi) _pendingViewerShowUi = true;
      return pendingJoin.then((joined) {
        if (mounted &&
            joined &&
            showLiveUi &&
            state.session?.liveId == cleanLiveId) {
          state = state.copyWith(hasLiveUi: true, clearError: true);
        }
        return joined;
      });
    }

    final generation = ++_transitionGeneration;
    _pendingViewerLiveId = cleanLiveId;
    _pendingViewerShowUi = showLiveUi;

    final transition = _enqueue<bool>(() async {
      if (cleanLiveId.isEmpty || generation != _transitionGeneration) {
        return false;
      }

      if (_isCurrentLive(cleanLiveId) && state.hasActiveRoom) {
        state = state.copyWith(
          hasLiveUi: _pendingViewerShowUi,
          clearError: true,
        );
        return true;
      }

      if (state.session != null || state.hasActiveRoom) {
        await _leaveCurrent(trackLeave: true);
      }
      if (generation != _transitionGeneration) return false;

      _seenReactionIds.clear();
      state = state.copyWith(
        status: LiveStatus.loading,
        clearLive: true,
        clearSession: true,
        clearRole: true,
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
        isPublishing: false,
        isSubscribed: false,
        clearActiveCohostId: true,
        hasLiveUi: false,
        viewerCount: 0,
        reactionTrigger: 0,
        lastReactionType: LiveReactionType.like,
        isMicMuted: true,
        isCameraEnabled: false,
        clearError: true,
      );

      try {
        final requestedSessionId = sessionId?.trim().isNotEmpty ?? false
            ? sessionId!.trim()
            : _viewerSessionIds[cleanLiveId];
        final bootstrap = await repository.joinLive(
          liveId: cleanLiveId,
          sessionId: requestedSessionId,
        );
        if (!mounted) return false;
        final canonicalSessionId = bootstrap.session.sessionId;
        if (canonicalSessionId != null && canonicalSessionId.isNotEmpty) {
          _rememberViewerSession(cleanLiveId, canonicalSessionId);
        }
        if (generation != _transitionGeneration) return false;

        if (!bootstrap.live.viewerState.canWatch ||
            !bootstrap.live.viewerState.canJoin) {
          state = state.copyWith(
            status: LiveStatus.ended,
            live: bootstrap.live,
            hasLiveUi: false,
            clearSession: true,
            clearRole: true,
          );
          return false;
        }

        _hydrate(bootstrap.live);
        state = state.copyWith(
          session: bootstrap.session,
          role: bootstrap.session.role,
          hasLiveUi: false,
          clearError: true,
        );

        final resumeHost =
            bootstrap.session.role == AOSLiveRole.host && showLiveUi;
        final connected = await _connectSession(
          bootstrap.session,
          generation: generation,
          micEnabled: resumeHost,
          cameraEnabled: resumeHost,
        );
        if (connected) {
          state = state.copyWith(hasLiveUi: _pendingViewerShowUi);
        }
        return connected;
      } on Object catch (error, stackTrace) {
        if (!mounted) return false;
        _setJoinFailure(error, stackTrace);
        return false;
      }
    });
    late final Future<bool> trackedTransition;
    trackedTransition = transition.whenComplete(() {
      if (identical(_pendingViewerJoin, trackedTransition)) {
        _pendingViewerLiveId = null;
        _pendingViewerJoin = null;
        _pendingViewerShowUi = false;
      }
    });
    _pendingViewerJoin = trackedTransition;
    return trackedTransition;
  }

  Future<bool> startCohostSession({
    required LiveJoinSession session,
    required String cohostId,
  }) {
    final generation = ++_transitionGeneration;
    return _enqueue<bool>(() async {
      final previousSession = state.session;
      if (previousSession == null ||
          previousSession.liveId != session.liveId ||
          previousSession.sessionId != session.sessionId ||
          state.isHost ||
          generation != _transitionGeneration) {
        return false;
      }

      try {
        await mediaService.leaveLive();
        if (!mounted) return false;
        state = state.copyWith(
          session: session,
          role: AOSLiveRole.cohost,
          roomState: RoomState.connecting,
          hasActiveRoom: false,
          isMicMuted: false,
          isCameraEnabled: true,
          activeCohostId: cohostId,
          clearError: true,
        );

        final connected = await _connectSession(
          session,
          generation: generation,
          micEnabled: true,
          cameraEnabled: true,
          frontCamera: state.isFrontCamera,
          joinSocketRoom: false,
          trackViewerJoin: false,
        );
        if (connected) return true;
      } on Object catch (error, stackTrace) {
        appLogger.e(
          'startCohostSession failed',
          error: error,
          stackTrace: stackTrace,
        );
      }

      await _recoverViewerSession(previousSession, generation: generation);
      return false;
    });
  }

  Future<bool> returnToViewer() {
    final generation = ++_transitionGeneration;
    return _enqueue<bool>(() async {
      final current = state.session;
      if (current == null || !state.isCohost || current.sessionId == null) {
        return false;
      }
      return _recoverViewerSession(current, generation: generation);
    });
  }

  Future<void> refreshActiveLive() {
    final existing = _activeRefresh;
    if (existing != null) return existing;

    late final Future<void> refresh;
    refresh =
        _enqueue<void>(() async {
          final session = state.session;
          if (session == null) return;

          try {
            final live = await repository.getLive(
              liveId: session.liveId,
              sessionId: session.sessionId,
            );
            if (!mounted) return;
            if (!_isCurrentLive(live.id)) return;

            if (!live.isActive || !live.viewerState.canWatch) {
              await _leaveCurrent(trackLeave: true);
              if (!mounted) return;
              state = state.copyWith(live: live).ended();
              return;
            }

            _hydrate(live);
            if ((state.isViewer || state.isCohost) &&
                session.sessionId != null) {
              final trackedLive = await repository.trackJoin(
                liveId: session.liveId,
                sessionId: session.sessionId!,
              );
              if (!mounted) return;
              if (trackedLive != null && _isCurrentLive(trackedLive.id)) {
                _hydrate(trackedLive);
              }
            }
          } on Failure catch (failure, stackTrace) {
            if (failure.error == 'NOT_FOUND' ||
                failure.error == 'INVALID_STATE' ||
                failure.error == 'PERMISSION_DENIED') {
              await _leaveCurrent(trackLeave: true);
              if (!mounted) return;
              state = state.ended();
              return;
            }
            appLogger.e(
              'refreshActiveLive failed',
              error: failure,
              stackTrace: stackTrace,
            );
          } on Object catch (error, stackTrace) {
            appLogger.e(
              'refreshActiveLive failed',
              error: error,
              stackTrace: stackTrace,
            );
          }
        }).whenComplete(() {
          if (identical(_activeRefresh, refresh)) _activeRefresh = null;
        });
    _activeRefresh = refresh;
    return refresh;
  }

  Future<void> setMicrophoneMuted(bool muted) async {
    if (!state.isBroadcaster || !state.hasActiveRoom) return;
    final previous = state.isMicMuted;
    state = state.copyWith(isMicMuted: muted, clearError: true);
    try {
      await mediaService.setMicrophoneEnabled(!muted);
    } on Object catch (error, stackTrace) {
      if (!mounted) return;
      state = state.copyWith(isMicMuted: previous);
      appLogger.e(
        'setMicrophoneMuted failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> flipCamera() async {
    if (!state.isBroadcaster || !state.hasActiveRoom) return;
    try {
      final switched = await mediaService.flipCamera();
      if (mounted && switched) {
        state = state.copyWith(isFrontCamera: !state.isFrontCamera);
      }
    } on Object catch (error, stackTrace) {
      appLogger.e('flipCamera failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> endLive() {
    ++_transitionGeneration;
    return _enqueue<void>(() async {
      final liveId = state.session?.liveId ?? state.live?.id;
      if (liveId == null || !state.isHost || state.isEnding) return;

      state = state.copyWith(isEnding: true, clearError: true);
      try {
        await repository.endLive(liveId: liveId);
        if (!mounted) return;
        await _leaveCurrent(trackLeave: false);
        if (!mounted) return;
        state = state.ended();
      } on Object catch (error, stackTrace) {
        if (!mounted) return;
        final message = _messageFor(error, fallback: 'Could not end Live.');
        state = state.copyWith(isEnding: false, errorMessage: message);
        appLogger.e('endLive failed', error: error, stackTrace: stackTrace);
      }
    });
  }

  Future<void> leaveLive() {
    ++_transitionGeneration;
    return _enqueue<void>(() async {
      await _leaveCurrent(trackLeave: true);
      if (!mounted) return;
      state = state.left();
    });
  }

  Future<void> leaveBackgroundLive(String liveId) async {
    if (state.hasLiveUi ||
        (_pendingViewerLiveId != liveId && !_isCurrentLive(liveId))) {
      return;
    }
    await leaveLive();
  }

  void hideLiveUi() {
    if (!state.hasLiveUi) return;
    state = state.copyWith(hasLiveUi: false);
  }

  Future<void> onLiveEndedEvent({required String liveId}) async {
    if (!_isCurrentLive(liveId)) return;
    ++_transitionGeneration;
    await _enqueue<void>(() async {
      await _leaveCurrent(trackLeave: true);
      if (!mounted) return;
      state = state.ended();
    });
  }

  void onLiveStartedEvent({required String liveId}) {
    if (!_isCurrentLive(liveId)) return;
    state = state.copyWith(status: LiveStatus.live, clearError: true);
  }

  void onViewerCountUpdatedEvent({
    required String liveId,
    required int viewerCount,
  }) {
    if (!_isCurrentLive(liveId)) return;
    final safeCount = viewerCount < 0 ? 0 : viewerCount;
    state = state.copyWith(
      viewerCount: safeCount,
      live: state.live?.copyWith(viewerCount: safeCount),
      clearError: true,
    );
  }

  void onLiveReactionEvent(LiveReaction reaction) {
    if (!_isCurrentLive(reaction.liveId) || reaction.id.isEmpty) return;
    if (!_seenReactionIds.add(reaction.id)) return;

    while (_seenReactionIds.length > 256) {
      _seenReactionIds.remove(_seenReactionIds.first);
    }

    final live = state.live;
    state = state.copyWith(
      live: live?.copyWith(reactionCount: live.reactionCount + 1),
      reactionTrigger: state.reactionTrigger + 1,
      lastReactionType: reaction.type,
      clearError: true,
    );
  }

  Future<bool> sendReaction(LiveReactionType type) async {
    final live = state.live;
    final session = state.session;
    if (_reactionInFlight ||
        live == null ||
        session == null ||
        !live.viewerState.canReact) {
      return false;
    }

    _reactionInFlight = true;
    state = state.copyWith(isReacting: true, clearError: true);
    try {
      final reaction = await repository.sendReaction(
        liveId: live.id,
        reactionType: type,
        sessionId: session.sessionId,
      );
      if (!mounted) return false;
      onLiveReactionEvent(reaction);
      return true;
    } on Object catch (error, stackTrace) {
      if (!mounted) return false;
      state = state.copyWith(
        errorMessage: _messageFor(error, fallback: 'Could not react.'),
      );
      appLogger.e('sendReaction failed', error: error, stackTrace: stackTrace);
      return false;
    } finally {
      _reactionInFlight = false;
      if (mounted) state = state.copyWith(isReacting: false);
    }
  }

  Future<bool> _connectSession(
    LiveJoinSession session, {
    required int generation,
    required bool micEnabled,
    required bool cameraEnabled,
    bool frontCamera = true,
    bool joinSocketRoom = true,
    bool trackViewerJoin = true,
  }) async {
    state = state.copyWith(
      roomState: RoomState.connecting,
      hasActiveRoom: false,
      isPublishing: false,
      isSubscribed: false,
      clearError: true,
    );

    try {
      if (joinSocketRoom) {
        try {
          await realtimeService.joinSocketRoom(session.liveId);
        } on Object catch (error, stackTrace) {
          appLogger.e(
            'Live realtime room join failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      if (!mounted) return false;

      await mediaService.joinLive(
        wsUrl: session.wsUrl,
        token: session.token,
        role: session.role,
        micEnabled: micEnabled,
        cameraEnabled: cameraEnabled,
        frontCamera: frontCamera,
      );

      if (!mounted || generation != _transitionGeneration) {
        await _leaveMediaSafely();
        return false;
      }

      final broadcaster =
          session.role == AOSLiveRole.host ||
          session.role == AOSLiveRole.cohost;
      state = state.copyWith(
        roomState: RoomState.connected,
        status: LiveStatus.live,
        hasActiveRoom: true,
        isPublishing: broadcaster && (micEnabled || cameraEnabled),
        isSubscribed: !broadcaster,
        isMicMuted: !micEnabled,
        isCameraEnabled: broadcaster && cameraEnabled,
        isFrontCamera: frontCamera,
        clearError: true,
      );

      if (trackViewerJoin &&
          session.role == AOSLiveRole.viewer &&
          session.sessionId != null) {
        final live = await repository.trackJoin(
          liveId: session.liveId,
          sessionId: session.sessionId!,
        );
        if (mounted && live != null && generation == _transitionGeneration) {
          _hydrate(live);
        }
      }

      if (mounted && generation == _transitionGeneration) return true;
      await _leaveCurrent(trackLeave: true);
      return false;
    } on Object catch (error, stackTrace) {
      if (session.role == AOSLiveRole.viewer && session.sessionId != null) {
        try {
          await repository.trackLeave(
            liveId: session.liveId,
            sessionId: session.sessionId!,
          );
        } on Object catch (trackingError, trackingStackTrace) {
          appLogger.e(
            'trackLeave after failed Live connection failed',
            error: trackingError,
            stackTrace: trackingStackTrace,
          );
        }
      }
      try {
        await realtimeService.leaveSocketRoom(session.liveId);
      } on Object catch (socketError, socketStackTrace) {
        appLogger.e(
          'Live socket room cleanup failed',
          error: socketError,
          stackTrace: socketStackTrace,
        );
      }
      await _leaveMediaSafely();
      if (!mounted) return false;
      final message = _messageFor(
        error,
        fallback: 'Could not connect to Live.',
      );
      state = state.copyWith(
        status: LiveStatus.error,
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
        isPublishing: false,
        isSubscribed: false,
        hasLiveUi: false,
        clearSession: true,
        clearRole: true,
        clearActiveCohostId: true,
        errorMessage: message,
      );
      appLogger.e(
        'LiveKit session connection failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _recoverViewerSession(
    LiveJoinSession previousSession, {
    required int generation,
  }) async {
    final sessionId = previousSession.sessionId;
    if (sessionId == null || generation != _transitionGeneration) return false;

    try {
      await mediaService.leaveLive();
      final bootstrap = await repository.joinLive(
        liveId: previousSession.liveId,
        sessionId: sessionId,
      );
      if (!mounted || generation != _transitionGeneration) return false;

      _hydrate(bootstrap.live);
      state = state.copyWith(
        session: bootstrap.session,
        role: AOSLiveRole.viewer,
        clearActiveCohostId: true,
      );
      return _connectSession(
        bootstrap.session,
        generation: generation,
        micEnabled: false,
        cameraEnabled: false,
        joinSocketRoom: false,
      );
    } on Object catch (error, stackTrace) {
      if (!mounted) return false;
      _setFailure('Viewer recovery failed', error, stackTrace);
      return false;
    }
  }

  Future<void> _leaveCurrent({required bool trackLeave}) async {
    final session = state.session;
    if (session == null) {
      await _leaveMediaSafely();
      return;
    }

    if (trackLeave &&
        session.role != AOSLiveRole.host &&
        session.sessionId != null) {
      try {
        await repository.trackLeave(
          liveId: session.liveId,
          sessionId: session.sessionId!,
        );
      } on Object catch (error, stackTrace) {
        appLogger.e(
          'trackLeave failed; local cleanup continues',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    try {
      await realtimeService.leaveSocketRoom(session.liveId);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Live realtime room leave failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await _leaveMediaSafely();
    if (!mounted) return;
    state = state.copyWith(
      roomState: RoomState.disconnected,
      hasActiveRoom: false,
      isPublishing: false,
      isSubscribed: false,
      clearSession: true,
      clearRole: true,
      clearActiveCohostId: true,
    );
  }

  void _hydrate(LiveStream live) {
    state = state.copyWith(
      live: live,
      viewerCount: live.viewerCount,
      status: live.isActive ? LiveStatus.live : LiveStatus.ended,
      clearError: true,
    );
  }

  void _onMediaEvent(MediaTrackEvent event) {
    if (!mounted) return;
    if (event is RoomReconnectingEvent) {
      state = state.copyWith(roomState: RoomState.reconnecting);
      return;
    }
    if (event is RoomReconnectedEvent) {
      state = state.copyWith(roomState: RoomState.connected);
      unawaited(refreshActiveLive());
      return;
    }
    if (event is RoomDisconnectedEvent && state.hasActiveRoom) {
      state = state.copyWith(
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
      );
    }
  }

  Future<void> _endStartedLiveSafely(String liveId) async {
    try {
      await repository.endLive(liveId: liveId);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Failed to close Live after media startup failure',
        error: error,
        stackTrace: stackTrace,
      );
    }
    await _leaveMediaSafely();
  }

  Future<void> _releasePreparedCameraSafely() async {
    try {
      await mediaService.releasePreparedCamera();
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Prepared Live camera cleanup failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _leaveMediaSafely() async {
    try {
      await mediaService.leaveLive();
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Live media cleanup failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _setFailure(String operation, Object error, StackTrace stackTrace) {
    state = state.copyWith(
      status: LiveStatus.error,
      roomState: RoomState.disconnected,
      hasActiveRoom: false,
      hasLiveUi: false,
      errorMessage: _messageFor(error, fallback: 'Something went wrong.'),
    );
    appLogger.e(operation, error: error, stackTrace: stackTrace);
  }

  void _setJoinFailure(Object error, StackTrace stackTrace) {
    if (error is Failure &&
        (error.error == 'NOT_FOUND' || error.error == 'INVALID_STATE')) {
      state = state.copyWith(
        status: LiveStatus.ended,
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
        hasLiveUi: false,
        clearSession: true,
        clearRole: true,
        clearActiveCohostId: true,
        clearError: true,
      );
    } else {
      _setFailure('joinLive failed', error, stackTrace);
      return;
    }
    appLogger.e('joinLive failed', error: error, stackTrace: stackTrace);
  }

  String _messageFor(Object error, {required String fallback}) {
    if (error is Failure && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }

  bool _isCurrentLive(String liveId) {
    return state.live?.id == liveId || state.session?.liveId == liveId;
  }

  void _rememberViewerSession(String liveId, String sessionId) {
    _viewerSessionIds.remove(liveId);
    _viewerSessionIds[liveId] = sessionId;
    while (_viewerSessionIds.length > 32) {
      _viewerSessionIds.remove(_viewerSessionIds.keys.first);
    }
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _transitionTail = _transitionTail.then<void>((_) async {
      try {
        completer.complete(await operation());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    ++_transitionGeneration;
    unawaited(_disposeResources());
    super.dispose();
  }

  Future<void> _disposeResources() async {
    await _mediaSubscription.cancel();
    await _leaveMediaSafely();
  }
}
