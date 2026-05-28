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
    videoUpgradeStatus:
        _cleanString(json['video_upgrade_status']) ??
        _cleanString(json['videoUpgradeStatus']) ??
        'none',
    videoUpgradeRequestedBy:
        _cleanString(json['video_upgrade_requested_by']) ??
        _cleanString(json['videoUpgradeRequestedBy']) ??
        _cleanString(json['requested_by']) ??
        _cleanString(json['actor']),
  );
}

CallLog mapCallLog(Map<String, dynamic> json) {
  final user =
      _cleanString(json['other_user']) ??
      _cleanString(json['user']) ??
      _cleanString(json['participant']) ??
      '';

  final displayName =
      _cleanString(json['other_display_name']) ??
      _cleanString(json['display_name']) ??
      _cleanString(json['user_display_name']) ??
      user;

  final historyCategory = _cleanString(json['history_category']);
  final status = _cleanString(json['status']) ?? historyCategory ?? 'ended';

  final direction = _cleanString(json['direction']) ?? 'incoming';

  final isMissed =
      json['is_missed'] == true ||
      json['is_missed'] == 1 ||
      historyCategory == 'missed' ||
      (direction == 'incoming' && status == 'cancelled') ||
      status == 'missed';

  return CallLog(
    id:
        _cleanString(json['id']) ??
        _cleanString(json['call_id']) ??
        _cleanString(json['latest_call_id']) ??
        '',
    conversationId: _cleanString(json['conversation_id']) ?? '',

    // Backend already gives the display target for current user.
    user: user,
    displayName: displayName,
    avatar:
        _cleanString(json['other_avatar']) ??
        _cleanString(json['avatar']) ??
        _cleanString(json['user_avatar']),

    direction: direction,
    status: status,

    isMissed: isMissed,

    callType: _parseCallType(json['call_type']?.toString()),

    duration: _parseInt(json['duration']),

    startedAt: _parseDate(json['started_at']),
    endedAt: _parseDate(json['ended_at']),
    createdAt:
        _parseDate(json['created_at']) ??
        _parseDate(json['latest_created_at']) ??
        _parseDate(json['last_call_at']) ??
        DateTime.now(),

    groupId:
        _cleanString(json['group_id']) ??
        _cleanString(json['group_key']) ??
        _cleanString(json['call_group_id']),
    latestCallId:
        _cleanString(json['latest_call_id']) ??
        _cleanString(
          json['latest_call'] is Map ? json['latest_call']['call_id'] : null,
        ) ??
        _cleanString(json['id']) ??
        _cleanString(json['call_id']),
    oldestCallId:
        _cleanString(json['oldest_call_id']) ??
        _cleanString(json['id']) ??
        _cleanString(json['call_id']) ??
        _cleanString(json['latest_call_id']),
    groupCount: _parseInt(json['group_count']) > 0
        ? _parseInt(json['group_count'])
        : _parseInt(json['call_count']) > 0
        ? _parseInt(json['call_count'])
        : _parseInt(json['count']) > 0
        ? _parseInt(json['count'])
        : 1,
  );
}

List<CallLog> mapCallLogList(dynamic payload) {
  final data = _extractCallList(payload);

  return data
      .whereType<Map>()
      .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
      .map(mapCallLog)
      .toList();
}

List<dynamic> _extractCallList(dynamic payload) {
  if (payload is List) return payload;

  if (payload is Map) {
    for (final key in const ['calls', 'logs', 'items', 'rows', 'data']) {
      final value = payload[key];
      if (value is List) return value;
    }
  }

  return const [];
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
