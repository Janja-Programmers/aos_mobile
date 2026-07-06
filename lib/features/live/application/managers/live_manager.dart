import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/application/state/live_state.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/application/state/room_state_enum.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:africaonlinestores/features/live/repository/live_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

class LiveManager extends StateNotifier<LiveState> {
  final LiveRepository repository;
  final LiveMediaService mediaService;
  final RealtimeService realtimeService;

  bool _isJoining = false;
  bool _isLeaving = false;

  LiveManager({
    required this.repository,
    required this.mediaService,
    required this.realtimeService,
  }) : super(LiveState.initial());

  Future<void> startLive({
    required String title,
    required String coverImage,
    required String coverMediaId,
    bool micEnabled = true,
    bool cameraEnabled = true,
    bool frontCamera = true,
  }) async {
    try {
      if (state.isLive || state.isLoading || state.hasActiveRoom) {
        appLogger.i('Already in live flow');
        return;
      }

      state = state.copyWith(
        status: LiveStatus.loading,
        hasLiveUi: false,
        isMicMuted: !micEnabled,
        isCameraEnabled: cameraEnabled,
        isFrontCamera: frontCamera,
        viewerCount: 0,
        clearError: true,
      );

      final session = await repository.startLive(
        title: title,
        coverImage: coverImage,
        coverMediaId: coverMediaId,
      );

      state = state.copyWith(
        session: session,
        role: session.role,
        hasLiveUi: true,
        isMicMuted: !micEnabled,
        isCameraEnabled: cameraEnabled,
        isFrontCamera: frontCamera,
        clearError: true,
      );

      await _joinRoomInternal(
        session,
        micEnabled: micEnabled,
        cameraEnabled: cameraEnabled,
        frontCamera: frontCamera,
      );
    } catch (e, s) {
      appLogger.e('startLive failed', error: e, stackTrace: s);

      final message = e is Failure ? e.message : 'Something went wrong';

      state = state.copyWith(
        status: LiveStatus.error,
        errorMessage: message,
        hasLiveUi: false,
      );
    }
  }

  Future<void> setMicrophoneMuted(bool muted) async {
    final previous = state.isMicMuted;
    state = state.copyWith(isMicMuted: muted, clearError: true);

    try {
      if (!state.hasActiveRoom) return;
      await mediaService.setMicrophoneEnabled(!muted);
    } catch (e, s) {
      appLogger.e('setMicrophoneMuted failed', error: e, stackTrace: s);
      state = state.copyWith(isMicMuted: previous);
    }
  }

  Future<void> flipCamera() async {
    try {
      if (!state.isBroadcaster || !state.hasActiveRoom) return;
      final switched = await mediaService.flipCamera();
      if (switched) {
        state = state.copyWith(isFrontCamera: !state.isFrontCamera);
      }
    } catch (e, s) {
      appLogger.e('flipCamera failed', error: e, stackTrace: s);
    }
  }

  Future<void> joinLive({required String liveId}) async {
    try {
      if (state.isLive || state.isLoading || state.hasActiveRoom) {
        appLogger.i('Already in live flow');
        return;
      }

      state = state.copyWith(
        status: LiveStatus.loading,
        hasLiveUi: true,
        viewerCount: 0,
        isMicMuted: true,
        isCameraEnabled: false,
        clearError: true,
      );

      final session = await repository.joinLive(liveId: liveId);

      state = state.copyWith(
        session: session,
        role: session.role,
        clearError: true,
      );

      await _joinRoomInternal(session, micEnabled: false, cameraEnabled: false);
    } catch (e, s) {
      appLogger.e('joinLive failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: LiveStatus.error,
        errorMessage: e is Failure ? e.message : e.toString(),
        hasLiveUi: false,
      );
    }
  }

  Future<void> startCohostSession(LiveJoinSession session) async {
    try {
      await mediaService.leaveLive();
      state = state.copyWith(
        session: session,
        role: session.role,
        isMicMuted: false,
        isCameraEnabled: true,
        clearError: true,
      );
      await _joinRoomInternal(session, frontCamera: state.isFrontCamera);
    } catch (e, s) {
      appLogger.e('startCohostSession failed', error: e, stackTrace: s);
      state = state.copyWith(
        status: LiveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> onLiveStartedEvent({required String liveId}) async {
    if (!_isCurrentLive(liveId)) return;
    state = state.copyWith(status: LiveStatus.live, clearError: true);
  }

  Future<void> onLiveEndedEvent({required String liveId}) async {
    if (!_isCurrentLive(liveId)) return;
    await _leaveRoomInternal();
    state = state.ended();
  }

  Future<void> onViewerCountUpdatedEvent({
    required String liveId,
    required int viewerCount,
  }) async {
    if (!_isCurrentLive(liveId)) return;

    state = state.copyWith(
      viewerCount: viewerCount,
      live: state.live?.copyWith(viewerCount: viewerCount),
      clearError: true,
    );

    appLogger.i('Viewer count updated → $viewerCount');
  }

  Future<void> onViewerJoinedEvent({
    required String liveId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isCurrentLive(liveId)) return;

    final displayName =
        data['display_name']?.toString() ??
        data['user']?.toString() ??
        data['session_id']?.toString() ??
        'Viewer';

    appLogger.i('Viewer joined current live → $displayName');
  }

  Future<void> onViewerLeftEvent({
    required String liveId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isCurrentLive(liveId)) return;

    final displayName =
        data['display_name']?.toString() ??
        data['user']?.toString() ??
        data['session_id']?.toString() ??
        'Viewer';

    appLogger.i('Viewer left current live → $displayName');
  }

  Future<void> onLiveCommentEvent({
    required String liveId,
    required Map<String, dynamic> comment,
  }) async {
    if (!_isCurrentLive(liveId)) return;
    appLogger.i('Live comment event received → ${comment['id']}');
  }

  Future<void> onLiveCommentDeletedEvent({
    required String liveId,
    required String commentId,
  }) async {
    if (!_isCurrentLive(liveId)) return;
    appLogger.i('Live comment deleted event received → $commentId');
  }

  Future<void> onLiveReactionEvent({
    required String liveId,
    required Map<String, dynamic> reaction,
  }) async {
    if (!_isCurrentLive(liveId)) return;
    appLogger.i('Live reaction event received → ${reaction['reaction_type']}');
  }

  Future<void> onLiveCohostEvent({
    required String liveId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isCurrentLive(liveId)) return;
    appLogger.i(
      'Live co-host event received → ${data['cohost_id'] ?? data['status'] ?? data}',
    );
  }

  Future<void> _joinRoomInternal(
    LiveJoinSession session, {
    bool micEnabled = true,
    bool cameraEnabled = true,
    bool frontCamera = true,
  }) async {
    if (_isJoining) return;
    _isJoining = true;

    try {
      state = state.copyWith(
        roomState: RoomState.connecting,
        hasActiveRoom: false,
        isPublishing: false,
        isSubscribed: false,
        clearError: true,
      );

      try {
        await realtimeService.joinSocketRoom(session.liveId);
      } catch (e, s) {
        appLogger.e(
          '[Realtime] Failed to join room, continuing anyway',
          error: e,
          stackTrace: s,
        );
      }

      appLogger.i('LIVEKIT wsUrl: ${session.wsUrl}');
      appLogger.i('LIVEKIT token empty: ${session.token.isEmpty}');
      appLogger.i('LIVEKIT liveId: ${session.liveId}');
      appLogger.i('LIVEKIT role: ${session.role}');

      await mediaService.joinLive(
        wsUrl: session.wsUrl,
        token: session.token,
        role: session.role,
        micEnabled: micEnabled,
        cameraEnabled: cameraEnabled,
        frontCamera: frontCamera,
      );

      final isBroadcaster =
          session.role == AOSLiveRole.host ||
          session.role == AOSLiveRole.cohost;

      state = state.copyWith(
        roomState: RoomState.connected,
        status: LiveStatus.live,
        hasActiveRoom: true,
        isPublishing: isBroadcaster,
        isSubscribed: !isBroadcaster,
        isMicMuted: !micEnabled,
        isCameraEnabled: isBroadcaster && cameraEnabled,
        isFrontCamera: frontCamera,
        clearError: true,
      );

      if (session.role == AOSLiveRole.viewer) {
        try {
          await repository.trackJoin(
            liveId: session.liveId,
            sessionId: session.sessionId,
          );
        } catch (e, s) {
          appLogger.e(
            'trackJoin failed, continuing session',
            error: e,
            stackTrace: s,
          );
        }
      }
    } catch (e, s) {
      appLogger.e('joinRoom failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: LiveStatus.error,
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
        isPublishing: false,
        isSubscribed: false,
        errorMessage: e.toString(),
      );
    } finally {
      _isJoining = false;
    }
  }

  Future<void> _leaveRoomInternal() async {
    if (_isLeaving) return;
    _isLeaving = true;

    final liveId = state.session?.liveId ?? state.live?.id;
    final sessionId = state.session?.sessionId;
    final shouldTrackLeave = state.isViewer || state.isCohost;

    try {
      if (shouldTrackLeave && liveId != null) {
        try {
          await repository.trackLeave(liveId: liveId, sessionId: sessionId);
          appLogger.i('Live viewer tracked leave → liveId=$liveId');
        } catch (e, s) {
          appLogger.e(
            'trackLeave failed, still leaving live room',
            error: e,
            stackTrace: s,
          );
        }
      }

      if (liveId != null) {
        try {
          await realtimeService.leaveSocketRoom(liveId);
          appLogger.i('[Realtime] Left room → live:$liveId');
        } catch (e, s) {
          appLogger.e(
            '[Realtime] Failed to leave room, continuing anyway',
            error: e,
            stackTrace: s,
          );
        }
      }

      await mediaService.leaveLive();

      state = state.copyWith(
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
        isPublishing: false,
        isSubscribed: false,
      );

      appLogger.i('Left live room');
    } catch (e, s) {
      appLogger.e('leaveRoom failed', error: e, stackTrace: s);
    } finally {
      _isLeaving = false;
    }
  }

  Future<void> endLive() async {
    try {
      final liveId = state.session?.liveId ?? state.live?.id;

      if (liveId != null && state.isHost) {
        await repository.endLive(liveId: liveId);
      }

      await _leaveRoomInternal();

      state = state.ended();
    } catch (e, s) {
      appLogger.e('endLive failed', error: e, stackTrace: s);
    }
  }

  Future<void> leaveLive() async {
    try {
      await _leaveRoomInternal();
      state = state.left();
      appLogger.i('Viewer left live');
    } catch (e, s) {
      appLogger.e('leaveLive failed', error: e, stackTrace: s);
    }
  }

  Future<void> sendReaction({String reactionType = 'like'}) async {
    try {
      final liveId = state.session?.liveId ?? state.live?.id;

      if (liveId == null) return;

      await repository.sendReaction(
        liveId: liveId,
        reactionType: reactionType,
        sessionId: state.session?.sessionId,
      );

      appLogger.i('Live reaction sent → $reactionType');
    } catch (e, s) {
      appLogger.e('sendReaction failed', error: e, stackTrace: s);
    }
  }

  bool _isCurrentLive(String liveId) {
    return state.live?.id == liveId || state.session?.liveId == liveId;
  }

  @override
  void dispose() {
    unawaited(mediaService.leaveLive());
    super.dispose();
  }
}
