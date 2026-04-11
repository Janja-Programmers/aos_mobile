import 'package:flutter/foundation.dart';

@immutable
class CallParticipant {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  const CallParticipant({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  CallParticipant copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
  }) {
    return CallParticipant(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
