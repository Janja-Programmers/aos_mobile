import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';

import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/application/state/live_state.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/application/state/room_state_enum.dart';
import 'package:africaonlinestores/features/live/repository/live_repository_impl.dart';

import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';

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

  // ================= START LIVE (HOST) =================

  Future<void> startLive({
    required String title,
    required String coverImage,
  }) async {
    try {
      if (state.isLive || state.isLoading || state.hasActiveRoom) {
        appLogger.i('❌ Already in live flow');
        return;
      }

      state = state.copyWith(
        status: LiveStatus.loading,
        hasLiveUi: false,
        clearError: true,
      );

      final session = await repository.startLive(
        title: title,
        coverImage: coverImage,
      );

      state = state.copyWith(
        session: session,
        role: AOSLiveRole.host,
        hasLiveUi: true,
        clearError: true,
      );

      await _joinRoomInternal(session);
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

  Future<void> flipCamera() async {
    try {
      if (!state.isHost || !state.hasActiveRoom) return;
      await mediaService.flipCamera();
    } catch (e, s) {
      appLogger.e('flipCamera failed', error: e, stackTrace: s);
    }
  }

  // ================= JOIN LIVE (VIEWER) =================

  Future<void> joinLive({required String liveId}) async {
    try {
      if (state.isLive || state.isLoading || state.hasActiveRoom) {
        appLogger.i('❌ Already in live flow');
        return;
      }

      state = state.copyWith(
        status: LiveStatus.loading,
        hasLiveUi: true,
        viewerCount: 0,
        clearError: true,
      );

      final session = await repository.joinLive(liveId: liveId);

      state = state.copyWith(
        session: session,
        role: session.role,
        clearError: true,
      );

      appLogger.i(
        '[LiveManager] 👥 Join Live Viewer state as he waits to _joinRoomInternal→ ${state.toString()}',
      );

      await _joinRoomInternal(session);
    } catch (e, s) {
      appLogger.e('joinLive failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: LiveStatus.error,
        errorMessage: e is Failure ? e.message : e.toString(),
        hasLiveUi: false,
      );
    }
  }

  // ================= SOCKET EVENTS =================

  Future<void> onLiveStartedEvent({required String liveId}) async {
    final isCurrentLive = _isCurrentLive(liveId);

    appLogger.i(
      '📡 Live started event → '
      'eventLiveId=$liveId, '
      'isCurrentLive=$isCurrentLive',
    );

    if (!isCurrentLive) return;

    state = state.copyWith(status: LiveStatus.live, clearError: true);
  }

  Future<void> onLiveEndedEvent({required String liveId}) async {
    final isCurrentLive = _isCurrentLive(liveId);

    if (!isCurrentLive) {
      appLogger.w(
        '⚠️ Ignoring live-ended event → '
        'eventLiveId=$liveId, '
        'stateLiveId=${state.live?.id}, '
        'sessionLiveId=${state.session?.liveId}, '
        'hasLiveUi=${state.hasLiveUi}, '
        'hasActiveRoom=${state.hasActiveRoom}',
      );
      return;
    }

    appLogger.i('📡 Host ended live → force closing room: $liveId');

    await _leaveRoomInternal();

    state = state.ended();
  }

  Future<void> onViewerCountUpdatedEvent({
    required String liveId,
    required int viewerCount,
  }) async {
    if (!_isCurrentLive(liveId)) {
      appLogger.w(
        '⚠️ Ignoring viewer count → '
        'eventLiveId=$liveId, '
        'stateLiveId=${state.live?.id}, '
        'sessionLiveId=${state.session?.liveId}',
      );
      return;
    }

    state = state.copyWith(viewerCount: viewerCount, clearError: true);
  }

  // ================= ROOM =================

  Future<void> _joinRoomInternal(LiveJoinSession session) async {
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

      // -----------------------------
      // 1. Join Frappe realtime room (NON-CRITICAL)
      // -----------------------------
      try {
        await realtimeService.joinRoom('live:${session.liveId}');
        appLogger.i('[Realtime] ✅ Joined room → live:${session.liveId}');
      } catch (e, s) {
        appLogger.e(
          '[Realtime] ❌ Failed to join room → continuing anyway',
          error: e,
          stackTrace: s,
        );
      }

      // -----------------------------
      // 2. Join LiveKit room (CRITICAL)
      // -----------------------------
      await mediaService.joinLive(
        wsUrl: session.wsUrl,
        token: session.token,
        role: session.role,
      );

      state = state.copyWith(
        roomState: RoomState.connected,
        status: LiveStatus.live,
        hasActiveRoom: true,
        isPublishing: session.role == AOSLiveRole.host,
        isSubscribed: session.role == AOSLiveRole.viewer,
        clearError: true,
      );

      appLogger.i('[LiveManager] 👥 Joined room → ${session.liveId}');

      // -----------------------------
      // 3. Track viewer join (NON-BLOCKING)
      // -----------------------------
      if (session.role == AOSLiveRole.viewer) {
        try {
          final viewId = await repository.trackJoin(liveId: session.liveId);

          appLogger.i('👀 Viewer tracked → viewId=$viewId');
        } catch (e, s) {
          appLogger.e(
            'trackJoin failed → continuing session',
            error: e,
            stackTrace: s,
          );
        }
      }

      appLogger.i('🎥 Joined live room successfully');
    } catch (e, s) {
      // ❌ ONLY critical failures reach here (LiveKit failure)
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
    final wasViewer = state.isViewer;

    try {
      if (wasViewer && liveId != null) {
        try {
          await repository.trackLeave(liveId: liveId);
          appLogger.i('👀 Live viewer tracked leave → liveId=$liveId');
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
          await realtimeService.leaveRoom('live:$liveId');
          appLogger.i('[Realtime] ✅ Left room → live:$liveId');
        } catch (e, s) {
          appLogger.e(
            '[Realtime] ❌ Failed to leave room → continuing anyway',
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

      appLogger.i('👋 Left live room');
    } catch (e, s) {
      appLogger.e('leaveRoom failed', error: e, stackTrace: s);
    } finally {
      _isLeaving = false;
    }
  }

  // ================= END LIVE =================

  Future<void> endLive() async {
    try {
      final liveId = state.session?.liveId ?? state.live?.id;

      if (liveId != null && state.isHost) {
        await repository.endLive(liveId: liveId);
      }

      await _leaveRoomInternal();

      state = state.ended();

      appLogger.i('🔚 Live ended by host');
    } catch (e, s) {
      appLogger.e('endLive failed', error: e, stackTrace: s);
    }
  }

  // ================= LEAVE LIVE =================

  Future<void> leaveLive() async {
    try {
      await _leaveRoomInternal();

      state = state.left();

      appLogger.i('👋 Viewer left live');
    } catch (e, s) {
      appLogger.e('leaveLive failed', error: e, stackTrace: s);
    }
  }

  // ================= SEND LIVE REACTIONS =================

  Future<void> sendReaction({String reactionType = 'like'}) async {
    try {
      final liveId = state.session?.liveId ?? state.live?.id;

      if (liveId == null) return;

      await repository.sendReaction(liveId: liveId, reactionType: reactionType);

      appLogger.i('❤️ Live reaction sent → $reactionType');
    } catch (e, s) {
      appLogger.e('sendReaction failed', error: e, stackTrace: s);
    }
  }

  // ================= HELPERS =================

  bool _isCurrentLive(String liveId) {
    return state.live?.id == liveId ||
        state.session?.liveId == liveId ||
        state.hasLiveUi ||
        state.hasActiveRoom;
  }

  // ================= CLEANUP =================

  @override
  void dispose() {
    // ❌ DO NOT dispose core media here
    super.dispose();
  }
}
