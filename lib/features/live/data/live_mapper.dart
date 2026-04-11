import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/domain/live_host.dart';
import 'package:africaonlinestores/features/live/domain/live_status.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';

AOSLiveStatus _parseStatus(String? status) {
  switch (status) {
    case 'live':
      return AOSLiveStatus.live;
    case 'ended':
      return AOSLiveStatus.ended;
    default:
      return AOSLiveStatus.scheduled;
  }
}

LiveHost _parseHost(dynamic json) {
  if (json == null) {
    return const LiveHost(userId: '', displayName: '');
  }

  if (json is Map<String, dynamic>) {
    return LiveHost(
      userId: json['user_id']?.toString() ?? '',
      displayName:
          json['display_name']?.toString() ??
          json['full_name']?.toString() ??
          '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  if (json is String) {
    return LiveHost(userId: json, displayName: json);
  }

  return const LiveHost(userId: '', displayName: '');
}

LiveStream mapLiveStream(Map<String, dynamic> json) {
  return LiveStream(
    id: json['live_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    roomName: json['room_name']?.toString() ?? '',
    status: _parseStatus(json['status']),
    host: _parseHost(json['host']),
    viewerCount: json['viewer_count'] ?? 0,
    startedAt: json['started_at'] != null
        ? DateTime.tryParse(json['started_at'])
        : null,
    endedAt: json['ended_at'] != null
        ? DateTime.tryParse(json['ended_at'])
        : null,
    coverImage: json['cover_image']?.toString(),
  );
}

LiveJoinSession mapJoinSession(
  Map<String, dynamic> json, {
  required AOSLiveRole role,
}) {
  return LiveJoinSession(
    liveId: json['live_id']?.toString() ?? '',
    roomName: json['room_name']?.toString() ?? '',
    token: json['token']?.toString() ?? '',
    wsUrl: json['ws_url']?.toString() ?? '',
    role: role,
  );
}
