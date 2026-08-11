import 'package:africaonlinestores/features/live/domain/live_role.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveJoinSession {
  final String liveId;
  final String roomName;
  final String token;
  final String wsUrl;
  final AOSLiveRole role;
  final String identity;
  final String? sessionId;

  const LiveJoinSession({
    required this.liveId,
    required this.roomName,
    required this.token,
    required this.wsUrl,
    required this.role,
    required this.identity,
    this.sessionId,
  });

  LiveJoinSession copyWith({
    String? liveId,
    String? roomName,
    String? token,
    String? wsUrl,
    AOSLiveRole? role,
    String? identity,
    String? sessionId,
  }) {
    return LiveJoinSession(
      liveId: liveId ?? this.liveId,
      roomName: roomName ?? this.roomName,
      token: token ?? this.token,
      wsUrl: wsUrl ?? this.wsUrl,
      role: role ?? this.role,
      identity: identity ?? this.identity,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
