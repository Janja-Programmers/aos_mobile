import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/domain/live_host.dart';
import 'package:africaonlinestores/features/live/domain/live_status.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:africaonlinestores/features/live/domain/live_viewer_state.dart';

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

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final v = value.toLowerCase().trim();
    return v == 'true' || v == '1' || v == 'yes';
  }
  return false;
}

LiveHost _parseHost(dynamic json) {
  if (json == null) {
    return const LiveHost(userId: '', displayName: '');
  }

  if (json is Map) {
    final map = Map<String, dynamic>.from(json);

    return LiveHost(
      userId:
          map['user_id']?.toString() ??
          map['user']?.toString() ??
          map['host_user']?.toString() ??
          '',
      displayName:
          map['display_name']?.toString() ??
          map['full_name']?.toString() ??
          map['user']?.toString() ??
          '',
      avatarUrl:
          map['avatar_url']?.toString() ??
          map['avatar']?.toString() ??
          map['host_avatar']?.toString(),
    );
  }

  if (json is String) {
    return LiveHost(userId: json, displayName: json);
  }

  return const LiveHost(userId: '', displayName: '');
}

LiveStream mapLiveStream(Map<String, dynamic> json) {
  return LiveStream(
    id: json['live_id']?.toString() ?? json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    roomName: json['room_name']?.toString() ?? '',
    status: _parseStatus(json['status']?.toString()),
    host: _parseHost(
      json['host'] ??
          {
            'user': json['host_user'],
            'display_name': json['host_display_name'],
            'avatar': json['host_avatar'],
          },
    ),

    viewerCount: _parseInt(json['viewer_count']),
    totalViews: _parseInt(json['total_views']),
    peakViewers: _parseInt(json['peak_viewers']),
    likeCount: _parseInt(json['like_count']),
    reactionCount: _parseInt(json['reaction_count']),
    commentCount: _parseInt(json['comment_count']),
    totalWatchTimeSeconds: _parseInt(json['total_watch_time_seconds']),
    durationSeconds: _parseInt(json['duration_seconds']),

    startedAt: json['started_at'] != null
        ? DateTime.tryParse(json['started_at'].toString())
        : null,
    endedAt: json['ended_at'] != null
        ? DateTime.tryParse(json['ended_at'].toString())
        : null,

    coverImage: json['cover_image']?.toString(),
    thumbnail: json['thumbnail']?.toString(),

    isActive: _parseBool(json['is_active']),

    hostUser: json['host_user']?.toString() ?? '',
    hostDisplayName: json['host_display_name']?.toString() ?? '',
    hostAvatar: json['host_avatar']?.toString(),

    viewerState: LiveViewerState.fromJson(
      json['viewer_state'] is Map
          ? Map<String, dynamic>.from(json['viewer_state'])
          : null,
    ),
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
