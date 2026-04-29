import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';

import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/application/state/room_state_enum.dart';

@immutable
class LiveState {
  final LiveStatus status;

  // Core
  final LiveStream? live;
  final LiveJoinSession? session;
  final AOSLiveRole? role;

  // Room
  final RoomState roomState;
  final bool hasActiveRoom;

  // Host / Viewer flags
  final bool isPublishing;
  final bool isSubscribed;

  // Metrics
  final int viewerCount;

  // UI
  final bool hasLiveUi;

  // Error
  final String? errorMessage;

  const LiveState({
    required this.status,
    required this.live,
    required this.session,
    required this.role,
    required this.roomState,
    required this.hasActiveRoom,
    required this.isPublishing,
    required this.isSubscribed,
    required this.viewerCount,
    required this.hasLiveUi,
    required this.errorMessage,
  });

  // ================= INITIAL =================
  factory LiveState.initial() {
    return const LiveState(
      status: LiveStatus.idle,
      live: null,
      session: null,
      role: null,
      roomState: RoomState.disconnected,
      hasActiveRoom: false,
      isPublishing: false,
      isSubscribed: false,
      viewerCount: 0,
      hasLiveUi: false,
      errorMessage: null,
    );
  }

  // ================= SAFE COPY =================
  LiveState copyWith({
    LiveStatus? status,
    LiveStream? live,
    LiveJoinSession? session,
    bool clearSession = false,
    AOSLiveRole? role,
    bool clearRole = false,
    RoomState? roomState,
    bool? hasActiveRoom,
    bool? isPublishing,
    bool? isSubscribed,
    int? viewerCount,
    bool? hasLiveUi,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LiveState(
      status: status ?? this.status,
      live: live ?? this.live,
      session: clearSession ? null : (session ?? this.session),
      role: clearRole ? null : (role ?? this.role),
      roomState: roomState ?? this.roomState,
      hasActiveRoom: hasActiveRoom ?? this.hasActiveRoom,
      isPublishing: isPublishing ?? this.isPublishing,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      viewerCount: viewerCount ?? this.viewerCount,
      hasLiveUi: hasLiveUi ?? this.hasLiveUi,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // ================= HARD RESET =================
  LiveState ended() {
    return LiveState(
      status: LiveStatus.ended,
      live: live, // keep reference if needed for UI
      session: null,
      role: null,
      roomState: RoomState.disconnected,
      hasActiveRoom: false,
      isPublishing: false,
      isSubscribed: false,
      viewerCount: 0,
      hasLiveUi: false,
      errorMessage: null,
    );
  }

  LiveState left() {
    return LiveState(
      status: LiveStatus.ended,
      live: live,
      session: null,
      role: null,
      roomState: RoomState.disconnected,
      hasActiveRoom: false,
      isPublishing: false,
      isSubscribed: false,
      viewerCount: 0,
      hasLiveUi: false,
      errorMessage: null,
    );
  }

  // ================= DERIVED =================

  Duration get duration {
    final startedAt = live?.startedAt;
    if (startedAt == null) return Duration.zero;

    return DateTime.now().difference(startedAt);
  }

  bool get isHost => role == AOSLiveRole.host;
  bool get isViewer => role == AOSLiveRole.viewer;

  bool get isLoading => status == LiveStatus.loading;
  bool get isLive => status == LiveStatus.live;
  bool get hasEnded => status == LiveStatus.ended;

  bool get canJoinRoom =>
      session != null && roomState == RoomState.disconnected;

  bool get canLeaveRoom => roomState == RoomState.connected;

  @override
  String toString() {
    return '''
LiveState(
  status: $status,
  role: $role,
  liveId: ${live?.id},
  roomState: $roomState,
  viewers: $viewerCount,
  publishing: $isPublishing,
  subscribed: $isSubscribed,
  hasRoom: $hasActiveRoom,
  error: $errorMessage
)
''';
  }
}
