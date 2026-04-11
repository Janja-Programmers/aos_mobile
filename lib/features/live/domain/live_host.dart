import 'package:flutter/foundation.dart';

@immutable
class LiveHost {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  const LiveHost({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  LiveHost copyWith({String? userId, String? displayName, String? avatarUrl}) {
    return LiveHost(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
