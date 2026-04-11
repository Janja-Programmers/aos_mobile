import 'package:africaonlinestores/features/calls/domain/call.dart';
import 'package:africaonlinestores/features/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/calls/domain/call_participant.dart';

AOSCallType _parseCallType(String? type) {
  switch (type) {
    case 'video':
      return AOSCallType.video;
    default:
      return AOSCallType.audio;
  }
}

// 🔥 FIXED: accept dynamic instead of Map
CallParticipant? _parseParticipant(dynamic json) {
  if (json == null) return null;

  // ✅ Case 1: backend sends object
  if (json is Map<String, dynamic>) {
    return CallParticipant(
      userId: json['user_id']?.toString() ?? '',
      displayName:
          json['display_name']?.toString() ??
          json['full_name']?.toString() ??
          json['email']?.toString() ??
          '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  // ✅ Case 2: backend sends string (your current case)
  if (json is String) {
    return CallParticipant(userId: json, displayName: json, avatarUrl: null);
  }

  // ❌ unknown type
  return null;
}

Call mapCall(Map<String, dynamic> json) {
  return Call(
    // 🔥 FIX: backend uses call_id, not id
    id: json['call_id']?.toString() ?? json['id']?.toString() ?? '',

    conversationId: json['conversation_id']?.toString() ?? '',
    callType: _parseCallType(json['call_type']),
    roomName: json['room_name']?.toString() ?? '',
    token: json['token']?.toString() ?? '',
    wsUrl: json['ws_url']?.toString() ?? '',

    caller: _parseParticipant(json['caller']),
    receiver: _parseParticipant(json['receiver']),
  );
}

CallLog mapCallLog(Map<String, dynamic> json) {
  return CallLog(
    id: json['id']?.toString() ?? '',
    conversationId: json['conversation_id']?.toString() ?? '',
    callType: _parseCallType(json['call_type']),
    status: json['status']?.toString() ?? '',
    direction: json['direction']?.toString() ?? '',
    caller: _parseParticipant(json['caller']),
    receiver: _parseParticipant(json['receiver']),
    duration: Duration(seconds: json['duration'] ?? 0),
    startedAt: json['started_at'] != null
        ? DateTime.tryParse(json['started_at'])
        : null,
    endedAt: json['ended_at'] != null
        ? DateTime.tryParse(json['ended_at'])
        : null,
  );
}
