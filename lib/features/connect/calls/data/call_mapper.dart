import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

AOSCallType _parseCallType(String? type) {
  switch (type?.trim().toLowerCase()) {
    case 'video':
      return AOSCallType.video;
    default:
      return AOSCallType.audio;
  }
}

CallParticipant? _parseCallSide({
  required dynamic user,
  dynamic displayName,
  dynamic avatar,
}) {
  final userId = _cleanString(user);

  if (userId == null) return null;

  return CallParticipant(
    userId: userId,
    displayName: _cleanString(displayName) ?? userId,
    avatarUrl: _cleanString(avatar),
  );
}

Call mapCall(Map<String, dynamic> json) {
  return Call(
    id: _cleanString(json['call_id']) ?? _cleanString(json['id']) ?? '',
    conversationId: _cleanString(json['conversation_id']) ?? '',
    callType: _parseCallType(json['call_type']?.toString()),
    roomName: _cleanString(json['room_name']) ?? '',
    token: _cleanString(json['token']) ?? '',
    wsUrl: _cleanString(json['ws_url']) ?? '',
    caller: _parseCallSide(
      user: json['caller'],
      displayName: json['caller_display_name'],
      avatar: json['caller_avatar'],
    ),
    receiver: _parseCallSide(
      user: json['receiver'],
      displayName: json['receiver_display_name'],
      avatar: json['receiver_avatar'],
    ),
  );
}

CallLog mapCallLog(Map<String, dynamic> json) {
  final user = _cleanString(json['other_user']) ?? '';

  final displayName = _cleanString(json['other_display_name']) ?? user;

  return CallLog(
    id: _cleanString(json['id']) ?? _cleanString(json['call_id']) ?? '',
    conversationId: _cleanString(json['conversation_id']) ?? '',

    // Backend already gives the display target for current user.
    user: user,
    displayName: displayName,
    avatar: _cleanString(json['other_avatar']),

    direction: _cleanString(json['direction']) ?? 'incoming',
    status: _cleanString(json['status']) ?? 'ended',

    isMissed: json['is_missed'] == true || json['is_missed'] == 1,

    callType: _parseCallType(json['call_type']?.toString()),

    duration: _parseInt(json['duration']),

    startedAt: _parseDate(json['started_at']),
    endedAt: _parseDate(json['ended_at']),
    createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
  );
}

String? _cleanString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }

  return text;
}

DateTime? _parseDate(dynamic value) {
  final text = _cleanString(value);
  if (text == null) return null;

  return DateTime.tryParse(text);
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
