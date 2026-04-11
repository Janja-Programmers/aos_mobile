import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/calls/application/state/call_status_enum.dart';

import 'package:africaonlinestores/features/calls/domain/call.dart';
import 'package:africaonlinestores/features/calls/domain/call_participant.dart';

@immutable
class CallState {
  final CallStatus status;
  final Call? activeCall;
  final CallParticipant? caller;
  final CallParticipant? receiver;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoEnabled;
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

  const CallState({
    required this.status,
    this.activeCall,
    this.caller,
    this.receiver,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isVideoEnabled,
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
  });

  factory CallState.initial() {
    return const CallState(
      status: CallStatus.idle,
      activeCall: null,
      caller: null,
      receiver: null,
      isMuted: false,
      isSpeakerOn: false,
      isVideoEnabled: true,
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
    );
  }

  bool get hasActiveCall =>
      status == CallStatus.dialing ||
      status == CallStatus.incoming ||
      status == CallStatus.ringing ||
      status == CallStatus.connecting ||
      status == CallStatus.connected;

  CallState copyWith({
    CallStatus? status,
    Call? activeCall,
    ValueGetter<Call?>? activeCallBuilder,
    CallParticipant? caller,
    ValueGetter<CallParticipant?>? callerBuilder,
    CallParticipant? receiver,
    ValueGetter<CallParticipant?>? receiverBuilder,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isVideoEnabled,
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
  }) {
    return CallState(
      status: status ?? this.status,
      activeCall: activeCallBuilder != null
          ? activeCallBuilder()
          : activeCall ?? this.activeCall,
      caller: callerBuilder != null ? callerBuilder() : caller ?? this.caller,
      receiver: receiverBuilder != null
          ? receiverBuilder()
          : receiver ?? this.receiver,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
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
    );
  }

  @override
  String toString() {
    return 'CallState('
        'status: $status, '
        'activeCall: ${activeCall?.id}, '
        'caller: ${caller?.userId}, '
        'receiver: ${receiver?.userId}, '
        'isMuted: $isMuted, '
        'isSpeakerOn: $isSpeakerOn, '
        'isVideoEnabled: $isVideoEnabled, '
        'duration: $duration, '
        'direction: $direction, '
        'hasIncomingCallUi: $hasIncomingCallUi, '
        'hasActiveRoom: $hasActiveRoom, '
        'roomName: $roomName'
        ')';
  }
}
