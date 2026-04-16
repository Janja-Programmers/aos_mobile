import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

@immutable
class CallState {
  final UiCallPhase uiPhase;
  final BackendCallStatus? backendStatus;
  final Room? room;
  final Call? activeCall;
  final CallParticipant? caller;
  final CallParticipant? receiver;
  final CallMediaMode callMediaMode;
  final bool isUpgradePending;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isRemoteVideoEnabled;
  final bool isLocalVideoEnabled;
  final Duration duration;
  final String? errorMessage;
  final bool isBusy;
  final bool hasIncomingCallUi;
  final bool hasActiveRoom;
  final String? direction;
  final String? roomName;
  final String? token;
  final String? wsUrl;
  // HISTORY
  final List<CallLog> callLogs;
  final bool isLoadingHistory;
  final String? historyErrorMessage;

  const CallState({
    required this.uiPhase,
    required this.backendStatus,
    this.room,
    this.activeCall,
    this.caller,
    this.receiver,
    required this.callMediaMode,
    required this.isUpgradePending,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isRemoteVideoEnabled,
    required this.isLocalVideoEnabled,
    required this.duration,
    this.errorMessage,
    required this.isBusy,
    required this.hasIncomingCallUi,
    required this.hasActiveRoom,
    this.direction,
    this.roomName,
    this.token,
    this.wsUrl,
    required this.callLogs,
    required this.isLoadingHistory,
    this.historyErrorMessage,
  });

  factory CallState.initial() {
    return const CallState(
      uiPhase: UiCallPhase.idle,
      backendStatus: null,
      room: null,
      activeCall: null,
      caller: null,
      receiver: null,
      callMediaMode: CallMediaMode.audio,
      isUpgradePending: false,
      isMuted: false,
      isSpeakerOn: false,
      isRemoteVideoEnabled: true,
      isLocalVideoEnabled: true,
      duration: Duration.zero,
      errorMessage: null,
      isBusy: false,
      hasIncomingCallUi: false,
      hasActiveRoom: false,
      direction: null,
      roomName: null,
      token: null,
      wsUrl: null,
      callLogs: [],
      isLoadingHistory: false,
      historyErrorMessage: null,
    );
  }

  bool get hasCallSession => uiPhase != UiCallPhase.idle;

  bool get isCallInProgress {
    return backendStatus == BackendCallStatus.initiated ||
        backendStatus == BackendCallStatus.ringing ||
        backendStatus == BackendCallStatus.ongoing;
  }

  CallState copyWith({
    UiCallPhase? uiPhase,
    BackendCallStatus? backendStatus,
    Room? room,
    Call? activeCall,
    ValueGetter<Call?>? activeCallBuilder,
    CallParticipant? caller,
    ValueGetter<CallParticipant?>? callerBuilder,
    CallParticipant? receiver,
    ValueGetter<CallParticipant?>? receiverBuilder,
    CallMediaMode? callMediaMode,
    bool? isUpgradePending,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isRemoteVideoEnabled,
    bool? isLocalVideoEnabled,
    Duration? duration,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isBusy,
    bool? hasIncomingCallUi,
    bool? hasActiveRoom,
    String? roomName,
    bool clearRoomName = false,
    String? direction,
    bool clearDirection = false,
    String? token,
    bool clearToken = false,
    String? wsUrl,
    bool clearWsUrl = false,
    List<CallLog>? callLogs,
    bool? isLoadingHistory,
    String? historyErrorMessage,
    bool clearHistoryErrorMessage = false,
  }) {
    return CallState(
      uiPhase: uiPhase ?? this.uiPhase,
      backendStatus: backendStatus ?? this.backendStatus,
      room: room ?? this.room,
      activeCall: activeCallBuilder != null
          ? activeCallBuilder()
          : activeCall ?? this.activeCall,
      caller: callerBuilder != null ? callerBuilder() : caller ?? this.caller,
      receiver: receiverBuilder != null
          ? receiverBuilder()
          : receiver ?? this.receiver,
      callMediaMode: callMediaMode ?? this.callMediaMode,
      isUpgradePending: isUpgradePending ?? this.isUpgradePending,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isRemoteVideoEnabled: isRemoteVideoEnabled ?? this.isRemoteVideoEnabled,
      isLocalVideoEnabled: isLocalVideoEnabled ?? this.isLocalVideoEnabled,
      duration: duration ?? this.duration,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      isBusy: isBusy ?? this.isBusy,
      hasIncomingCallUi: hasIncomingCallUi ?? this.hasIncomingCallUi,
      hasActiveRoom: hasActiveRoom ?? this.hasActiveRoom,
      direction: clearDirection ? null : direction ?? this.direction,
      roomName: clearRoomName ? null : roomName ?? this.roomName,
      token: clearToken ? null : token ?? this.token,
      wsUrl: clearWsUrl ? null : wsUrl ?? this.wsUrl,

      callLogs: callLogs ?? this.callLogs,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      historyErrorMessage: clearHistoryErrorMessage
          ? null
          : historyErrorMessage ?? this.historyErrorMessage,
    );
  }

  @override
  String toString() {
    return 'CallState('
        'uiPhase: $uiPhase, '
        'backendStatus: $backendStatus, '
        'room: $room, '
        'activeCall: ${activeCall?.id}, '
        'caller: ${caller?.userId}, '
        'receiver: ${receiver?.userId}, '
        'callMediaMode: $callMediaMode, '
        'isUpgradePending: $isUpgradePending, '
        'isMuted: $isMuted, '
        'isSpeakerOn: $isSpeakerOn, '
        'duration: $duration, '
        'direction: $direction, '
        'hasIncomingCallUi: $hasIncomingCallUi, '
        'hasActiveRoom: $hasActiveRoom, '
        'roomName: $roomName, '
        'callLogsCount: ${callLogs.length}, '
        'isLoadingHistory: $isLoadingHistory'
        ')';
  }
}
