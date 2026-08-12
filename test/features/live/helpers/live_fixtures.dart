import 'package:africaonlinestores/features/live/data/live_mapper.dart';
import 'package:africaonlinestores/features/live/domain/live_bootstrap.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';

const String testLiveId = 'LIVE-2026-00001';
const String secondTestLiveId = 'LIVE-2026-00002';
const String testViewerSessionId = 'viewer-session-001';

Map<String, dynamic> liveJson({
  String liveId = testLiveId,
  String status = 'live',
  bool isActive = true,
  int viewerCount = 7,
  int reactionCount = 4,
  bool isHost = false,
  bool canJoin = true,
  bool canWatch = true,
  bool canComment = true,
  bool canReact = true,
}) {
  return <String, dynamic>{
    'live_id': liveId,
    'title': 'Test Live',
    'room_name': 'room-$liveId',
    'status': status,
    'host': <String, dynamic>{
      'user_id': 'ACC-2026-00001',
      'display_name': 'Test Host',
      'avatar_url': '/files/host.png',
      'is_verified': true,
      'total_followers': 120,
    },
    'viewer_count': viewerCount,
    'total_views': 10,
    'total_joins': 9,
    'unique_viewers': 8,
    'peak_viewers': 7,
    'like_count': 3,
    'reaction_count': reactionCount,
    'comment_count': 2,
    'total_watch_time_seconds': 300,
    'duration_seconds': 45,
    'started_at': '2026-08-11T10:00:00Z',
    'cover_image': '/files/live-cover.jpg',
    'is_active': isActive,
    'host_user': 'ACC-2026-00001',
    'host_display_name': 'Test Host',
    'host_avatar': '/files/host.png',
    'viewer_state': <String, dynamic>{
      'target_user': 'ACC-2026-00001',
      'is_host': isHost,
      'is_owner': isHost,
      'can_join': canJoin,
      'can_watch': canWatch,
      'can_comment': canComment,
      'can_react': canReact,
      'can_end': isHost,
      'can_report': !isHost,
      'can_request_cohost': !isHost,
      'can_invite_cohost': isHost,
    },
  };
}

LiveStream testLive({
  String liveId = testLiveId,
  String status = 'live',
  bool isActive = true,
  int viewerCount = 7,
  int reactionCount = 4,
  bool isHost = false,
  bool canJoin = true,
  bool canWatch = true,
  bool canComment = true,
  bool canReact = true,
}) {
  return mapLiveStream(
    liveJson(
      liveId: liveId,
      status: status,
      isActive: isActive,
      viewerCount: viewerCount,
      reactionCount: reactionCount,
      isHost: isHost,
      canJoin: canJoin,
      canWatch: canWatch,
      canComment: canComment,
      canReact: canReact,
    ),
  );
}

LiveJoinSession testSession({
  String liveId = testLiveId,
  AOSLiveRole role = AOSLiveRole.viewer,
  String? sessionId = testViewerSessionId,
}) {
  return LiveJoinSession(
    liveId: liveId,
    roomName: 'room-$liveId',
    token: 'test-token-$liveId',
    wsUrl: 'wss://livekit.example.invalid',
    role: role,
    identity: 'aos:participant:test-identity',
    sessionId: sessionId,
  );
}

LiveBootstrap testBootstrap({
  String liveId = testLiveId,
  AOSLiveRole role = AOSLiveRole.viewer,
  String? sessionId = testViewerSessionId,
  bool isHost = false,
}) {
  return LiveBootstrap(
    live: testLive(liveId: liveId, isHost: isHost),
    session: testSession(
      liveId: liveId,
      role: role,
      sessionId: sessionId,
    ),
  );
}

Map<String, dynamic> bootstrapData({
  String liveId = testLiveId,
  String role = 'viewer',
  bool includeSessionId = true,
}) {
  return <String, dynamic>{
    'live': liveJson(liveId: liveId, isHost: role == 'host'),
    'session': <String, dynamic>{
      'live_id': liveId,
      'room_name': 'room-$liveId',
      'token': 'test-token-$liveId',
      'ws_url': 'wss://livekit.example.invalid',
      'role': role,
      'identity': 'aos:participant:test-identity',
      if (includeSessionId) 'session_id': testViewerSessionId,
    },
  };
}

Map<String, dynamic> successEnvelope(Map<String, dynamic> data) {
  return <String, dynamic>{
    'message': <String, dynamic>{
      'ok': true,
      'message': 'OK',
      'data': data,
    },
  };
}
