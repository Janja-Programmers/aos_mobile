import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/connect/calls/domain/call.dart';

@immutable
class CallLog {
  final String id;
  final String conversationId;
  final String user;

  final String displayName;
  final String? avatar;

  final String direction; // incoming / outgoing
  final String status; // missed / ended / rejected

  final bool isMissed;

  final AOSCallType callType;

  final int duration; // seconds

  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  const CallLog({
    required this.id,
    required this.conversationId,
    required this.user,
    required this.displayName,
    this.avatar,
    required this.direction,
    required this.status,
    required this.isMissed,
    required this.callType,
    required this.duration,
    required this.startedAt,
    required this.endedAt,
    required this.createdAt,
  });

  // ================= HELPERS =================

  bool get isIncoming => direction == "incoming";
  bool get isOutgoing => direction == "outgoing";

  bool get isAnswered => status == "ended";

  String get formattedTime {
    final dt = startedAt ?? createdAt;
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  DateTime get date => createdAt;

  // ================= COPY =================

  CallLog copyWith({
    String? id,
    String? conversationId,
    String? user,
    String? displayName,
    String? avatar,
    String? direction,
    String? status,
    bool? isMissed,
    AOSCallType? callType,
    int? duration,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
  }) {
    return CallLog(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      isMissed: isMissed ?? this.isMissed,
      callType: callType ?? this.callType,
      duration: duration ?? this.duration,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
