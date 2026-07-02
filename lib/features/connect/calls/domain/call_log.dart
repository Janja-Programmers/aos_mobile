import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:flutter/foundation.dart';

@immutable
class CallLog {
  final String id;
  final String conversationId;
  final String user;

  final String displayName;
  final String? avatar;

  final String direction; // incoming / outgoing
  final String status; // missed / ended / rejected / cancelled

  final bool isMissed;

  final AOSCallType callType;

  final int duration; // seconds

  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  final String? groupId;
  final String? latestCallId;
  final String? oldestCallId;

  final int groupCount;

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
    this.groupId,
    this.latestCallId,
    this.oldestCallId,
    this.groupCount = 1,
  });

  // ================= HELPERS =================

  bool get isIncoming => direction == 'incoming';
  bool get isOutgoing => direction == 'outgoing';

  bool get isAnswered => status == 'ended';

  bool get isGrouped => groupCount > 1;

  String get detailLookupId =>
      latestCallId?.trim().isNotEmpty ?? false ? latestCallId! : id;

  String get effectiveLatestCallId =>
      latestCallId?.trim().isNotEmpty ?? false ? latestCallId! : id;

  String get effectiveOldestCallId =>
      oldestCallId?.trim().isNotEmpty ?? false ? oldestCallId! : id;

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
    String? groupId,
    String? latestCallId,
    String? oldestCallId,
    int? groupCount,
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
      groupId: groupId ?? this.groupId,
      latestCallId: latestCallId ?? this.latestCallId,
      oldestCallId: oldestCallId ?? this.oldestCallId,
      groupCount: groupCount ?? this.groupCount,
    );
  }
}
