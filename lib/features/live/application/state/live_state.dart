import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/features/live/application/state/room_state_enum.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:flutter/foundation.dart';

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

  // Local media state
  final bool isMicMuted;
  final bool isCameraEnabled;
  final bool isFrontCamera;

  // Metrics
  final int viewerCount;
  final int reactionTrigger;
  final LiveReactionType lastReactionType;

  // UI
  final bool hasLiveUi;
  final bool isEnding;
  final bool isReacting;
  final String? activeCohostId;

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
    required this.isMicMuted,
    required this.isCameraEnabled,
    required this.isFrontCamera,
    required this.viewerCount,
    required this.reactionTrigger,
    required this.lastReactionType,
    required this.hasLiveUi,
    required this.isEnding,
    required this.isReacting,
    required this.activeCohostId,
    required this.errorMessage,
  });

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
      isMicMuted: false,
      isCameraEnabled: true,
      isFrontCamera: true,
      viewerCount: 0,
      reactionTrigger: 0,
      lastReactionType: LiveReactionType.like,
      hasLiveUi: false,
      isEnding: false,
      isReacting: false,
      activeCohostId: null,
      errorMessage: null,
    );
  }

  LiveState copyWith({
    LiveStatus? status,
    LiveStream? live,
    bool clearLive = false,
    LiveJoinSession? session,
    bool clearSession = false,
    AOSLiveRole? role,
    bool clearRole = false,
    RoomState? roomState,
    bool? hasActiveRoom,
    bool? isPublishing,
    bool? isSubscribed,
    bool? isMicMuted,
    bool? isCameraEnabled,
    bool? isFrontCamera,
    int? viewerCount,
    int? reactionTrigger,
    LiveReactionType? lastReactionType,
    bool? hasLiveUi,
    bool? isEnding,
    bool? isReacting,
    String? activeCohostId,
    bool clearActiveCohostId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LiveState(
      status: status ?? this.status,
      live: clearLive ? null : live ?? this.live,
      session: clearSession ? null : session ?? this.session,
      role: clearRole ? null : role ?? this.role,
      roomState: roomState ?? this.roomState,
      hasActiveRoom: hasActiveRoom ?? this.hasActiveRoom,
      isPublishing: isPublishing ?? this.isPublishing,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      viewerCount: viewerCount ?? this.viewerCount,
      reactionTrigger: reactionTrigger ?? this.reactionTrigger,
      lastReactionType: lastReactionType ?? this.lastReactionType,
      hasLiveUi: hasLiveUi ?? this.hasLiveUi,
      isEnding: isEnding ?? this.isEnding,
      isReacting: isReacting ?? this.isReacting,
      activeCohostId: clearActiveCohostId
          ? null
          : activeCohostId ?? this.activeCohostId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  LiveState ended() {
    return LiveState(
      status: LiveStatus.ended,
      live: live,
      session: null,
      role: null,
      roomState: RoomState.disconnected,
      hasActiveRoom: false,
      isPublishing: false,
      isSubscribed: false,
      isMicMuted: false,
      isCameraEnabled: true,
      isFrontCamera: true,
      viewerCount: 0,
      reactionTrigger: reactionTrigger,
      lastReactionType: lastReactionType,
      hasLiveUi: false,
      isEnding: false,
      isReacting: false,
      activeCohostId: null,
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
      isMicMuted: false,
      isCameraEnabled: true,
      isFrontCamera: true,
      viewerCount: 0,
      reactionTrigger: reactionTrigger,
      lastReactionType: lastReactionType,
      hasLiveUi: false,
      isEnding: false,
      isReacting: false,
      activeCohostId: null,
      errorMessage: null,
    );
  }

  bool get isHost => role == AOSLiveRole.host;
  bool get isViewer => role == AOSLiveRole.viewer;
  bool get isCohost => role == AOSLiveRole.cohost;
  bool get isBroadcaster => isHost || isCohost;

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
  liveId: ${live?.id ?? session?.liveId},
  roomState: $roomState,
  viewers: $viewerCount,
  publishing: $isPublishing,
  subscribed: $isSubscribed,
  hasRoom: $hasActiveRoom,
  micMuted: $isMicMuted,
  cameraEnabled: $isCameraEnabled,
  frontCamera: $isFrontCamera,
  error: $errorMessage
)
''';
  }
}
