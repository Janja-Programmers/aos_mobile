import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/live/domain/live_role.dart';

@immutable
class LiveJoinSession {
  final String liveId;
  final String roomName;
  final String token;
  final String wsUrl;
  final AOSLiveRole role;

  const LiveJoinSession({
    required this.liveId,
    required this.roomName,
    required this.token,
    required this.wsUrl,
    required this.role,
  });

  LiveJoinSession copyWith({
    String? liveId,
    String? roomName,
    String? token,
    String? wsUrl,
    AOSLiveRole? role,
  }) {
    return LiveJoinSession(
      liveId: liveId ?? this.liveId,
      roomName: roomName ?? this.roomName,
      token: token ?? this.token,
      wsUrl: wsUrl ?? this.wsUrl,
      role: role ?? this.role,
    );
  }
}
