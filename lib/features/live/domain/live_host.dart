import 'package:flutter/foundation.dart';

@immutable
class LiveHost {
  const LiveHost({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.totalFollowers = 0,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final int totalFollowers;

  LiveHost copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    bool? isVerified,
    int? totalFollowers,
  }) {
    return LiveHost(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      totalFollowers: totalFollowers ?? this.totalFollowers,
    );
  }
}
