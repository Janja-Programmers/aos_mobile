import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

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

  bool _isJoining = false;
  bool _isLeaving = false;

  LiveManager({required this.repository, required this.mediaService})
    : super(LiveState.initial());

  // ================= START LIVE (HOST) =================
  Future<void> startLive({required String title}) async {
    try {
      if (state.isLive || state.isLoading) {
        appLogger.i('❌ Already in live flow');
        return;
      }

      state = state.copyWith(
        status: LiveStatus.loading,
        hasLiveUi: true,
        errorMessage: null,
      );

      final session = await repository.startLive(title: title);

      state = state.copyWith(session: session, role: AOSLiveRole.host);

      await _joinRoomInternal(session);
    } catch (e, s) {
      appLogger.e('startLive failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: LiveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ================= JOIN LIVE (VIEWER) =================
  Future<void> joinLive({required String liveId}) async {
    try {
      state = state.copyWith(
        status: LiveStatus.loading,
        hasLiveUi: true,
        errorMessage: null,
      );

      final session = await repository.joinLive(liveId: liveId);

      state = state.copyWith(session: session, role: session.role);

      await _joinRoomInternal(session);
    } catch (e, s) {
      appLogger.e('joinLive failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: LiveStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ================= SOCKET EVENTS =================

  Future<void> onLiveStartedEvent({required String liveId}) async {
    appLogger.i('📡 Live started event → $liveId');

    state = state.copyWith(status: LiveStatus.live);
  }

  Future<void> onLiveEndedEvent({required String liveId}) async {
    if (state.session?.liveId != liveId) return;

    appLogger.i('📡 Live ended → leaving room');

    await _leaveRoomInternal();

    state = state.copyWith(
      status: LiveStatus.ended,
      hasLiveUi: false,
      session: null,
      hasActiveRoom: false,
    );
  }

  Future<void> onViewerCountUpdatedEvent({
    required String liveId,
    required int viewerCount,
  }) async {
    if (state.session?.liveId != liveId) return;

    state = state.copyWith(viewerCount: viewerCount);
  }

  // ================= ROOM =================

  Future<void> _joinRoomInternal(LiveJoinSession session) async {
    if (_isJoining) return;
    _isJoining = true;

    try {
      state = state.copyWith(roomState: RoomState.connecting);

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
      );

      appLogger.i('🎥 Joined live room');
    } catch (e, s) {
      appLogger.e('joinRoom failed', error: e, stackTrace: s);

      state = state.copyWith(
        status: LiveStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      _isJoining = false;
    }
  }

  Future<void> _leaveRoomInternal() async {
    if (_isLeaving) return;
    _isLeaving = true;

    try {
      await mediaService.leaveLive();

      state = state.copyWith(
        roomState: RoomState.disconnected,
        hasActiveRoom: false,
        isPublishing: false,
        isSubscribed: false,
      );

      appLogger.i('👋 Left live room');
    } finally {
      _isLeaving = false;
    }
  }

  // ================= END LIVE =================
  Future<void> endLive() async {
    try {
      final liveId = state.session?.liveId;

      if (liveId != null && state.isHost) {
        await repository.endLive(liveId: liveId);
      }

      await _leaveRoomInternal();

      state = state.copyWith(
        status: LiveStatus.ended,
        hasLiveUi: false,
        session: null,
      );

      appLogger.i('🔚 Live ended');
    } catch (e, s) {
      appLogger.e('endLive failed', error: e, stackTrace: s);
    }
  }

  // ================= LEAVE LIVE =================

  Future<void> leaveLive() async {
    try {
      await _leaveRoomInternal();

      state = state.copyWith(
        status: LiveStatus.ended,
        hasLiveUi: false,
        session: null,
      );

      appLogger.i('👋 Viewer left live');
    } catch (e, s) {
      appLogger.e('leaveLive failed', error: e, stackTrace: s);
    }
  }

  // ================= CLEANUP =================
  @override
  void dispose() {
    // ❌ DO NOT dispose core media here
    super.dispose();
  }
}
