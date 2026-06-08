import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

enum AOSCallType { audio, video }

@immutable
class Call {
  final String id;
  final String conversationId;
  final AOSCallType callType;
  final String roomName;
  final String token;
  final String wsUrl;
  final CallParticipant? caller;
  final CallParticipant? receiver;

  final String videoUpgradeStatus;
  final String? videoUpgradeRequestedBy;

  const Call({
    required this.id,
    required this.conversationId,
    required this.callType,
    required this.roomName,
    required this.token,
    required this.wsUrl,
    this.caller,
    this.receiver,
    this.videoUpgradeStatus = 'none',
    this.videoUpgradeRequestedBy,
  });

  Call copyWith({
    String? id,
    String? conversationId,
    AOSCallType? callType,
    String? roomName,
    String? token,
    String? wsUrl,
    CallParticipant? caller,
    CallParticipant? receiver,
    String? videoUpgradeStatus,
    String? videoUpgradeRequestedBy,
    bool clearVideoUpgradeRequestedBy = false,
  }) {
    return Call(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      callType: callType ?? this.callType,
      roomName: roomName ?? this.roomName,
      token: token ?? this.token,
      wsUrl: wsUrl ?? this.wsUrl,
      caller: caller ?? this.caller,
      receiver: receiver ?? this.receiver,
      videoUpgradeStatus: videoUpgradeStatus ?? this.videoUpgradeStatus,
      videoUpgradeRequestedBy: clearVideoUpgradeRequestedBy
          ? null
          : videoUpgradeRequestedBy ?? this.videoUpgradeRequestedBy,
    );
  }
}
