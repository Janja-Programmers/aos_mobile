import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/calls/domain/call.dart';
import 'package:africaonlinestores/features/calls/domain/call_participant.dart';

@immutable
class CallLog {
  final String id;
  final String conversationId;
  final AOSCallType callType;
  final String status;
  final String direction;
  final CallParticipant? caller;
  final CallParticipant? receiver;
  final Duration duration;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const CallLog({
    required this.id,
    required this.conversationId,
    required this.callType,
    required this.status,
    required this.direction,
    this.caller,
    this.receiver,
    required this.duration,
    this.startedAt,
    this.endedAt,
  });
}
