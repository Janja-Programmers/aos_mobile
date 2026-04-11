import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/live/domain/live_host.dart';
import 'package:africaonlinestores/features/live/domain/live_status.dart';

@immutable
class LiveStream {
  final String id;
  final String title;
  final String roomName;
  final AOSLiveStatus status;
  final LiveHost host;
  final int viewerCount;

  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? coverImage;

  const LiveStream({
    required this.id,
    required this.title,
    required this.roomName,
    required this.status,
    required this.host,
    required this.viewerCount,
    this.startedAt,
    this.endedAt,
    this.coverImage,
  });

  LiveStream copyWith({
    String? id,
    String? title,
    String? roomName,
    AOSLiveStatus? status,
    LiveHost? host,
    int? viewerCount,
    DateTime? startedAt,
    DateTime? endedAt,
    String? coverImage,
  }) {
    return LiveStream(
      id: id ?? this.id,
      title: title ?? this.title,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      host: host ?? this.host,
      viewerCount: viewerCount ?? this.viewerCount,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}
