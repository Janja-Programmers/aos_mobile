import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

AOSCallType _parseCallType(String? type) {
  switch (type) {
    case 'video':
      return AOSCallType.video;
    default:
      return AOSCallType.audio;
  }
}

CallParticipant? _parseParticipant(dynamic json) {
  if (json == null) return null;

  if (json is String) {
    final value = json.trim();

    if (value.isEmpty) return null;

    return CallParticipant(
      userId: value,
      displayName: value.contains('@') ? value.split('@').first : 'Guest',
      avatarUrl: null,
    );
  }

  if (json is Map<String, dynamic>) {
    final userId =
        json['user_id']?.toString() ??
        json['id']?.toString() ??
        json['uuid']?.toString() ??
        '';

    final displayName = json['display_name']?.toString().trim();
    final fullName = json['full_name']?.toString().trim();
    final name = json['name']?.toString().trim();
    final email = json['email']?.toString().trim();

    return CallParticipant(
      userId: userId,
      displayName: displayName?.isNotEmpty == true
          ? displayName!
          : fullName?.isNotEmpty == true
          ? fullName!
          : name?.isNotEmpty == true
          ? name!
          : email?.isNotEmpty == true
          ? email!
          : 'Guest',
      avatarUrl:
          json['avatar_url']?.toString() ??
          json['avatar']?.toString() ??
          json['profile_image']?.toString(),
    );
  }

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
  DateTime? parse(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  return CallLog(
    id: json['id']?.toString() ?? '',
    conversationId: json['conversation_id']?.toString() ?? '',
    user: json['user']?.toString() ?? '',

    displayName: json['display_name']?.toString() ?? 'Guest',
    avatar: json['avatar']?.toString(),

    direction: json['direction']?.toString() ?? 'incoming',
    status: json['status']?.toString() ?? 'ended',

    isMissed: json['is_missed'] == true,

    callType: _parseCallType(json['call_type']),

    // ✅ FIX: keep as int (seconds)
    duration: json['duration'] is int
        ? json['duration']
        : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,

    startedAt: parse(json['started_at']?.toString()),
    endedAt: parse(json['ended_at']?.toString()),

    // ✅ IMPORTANT for grouping (Today / Yesterday)
    createdAt: parse(json['created_at']?.toString()) ?? DateTime.now(),
  );
}
