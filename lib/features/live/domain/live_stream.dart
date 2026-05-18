import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/live/domain/live_host.dart';
import 'package:africaonlinestores/features/live/domain/live_status.dart';
import 'package:africaonlinestores/features/live/domain/live_viewer_state.dart';

@immutable
class LiveStream {
  final String id;
  final String title;
  final String roomName;
  final AOSLiveStatus status;
  final LiveHost host;

  final int viewerCount;
  final int totalViews;
  final int peakViewers;
  final int likeCount;
  final int reactionCount;
  final int commentCount;
  final int totalWatchTimeSeconds;
  final int durationSeconds;

  final DateTime? startedAt;
  final DateTime? endedAt;

  final String? coverImage;
  final String? thumbnail;

  final bool isActive;

  final String hostUser;
  final String hostDisplayName;
  final String? hostAvatar;

  final LiveViewerState viewerState;

  const LiveStream({
    required this.id,
    required this.title,
    required this.roomName,
    required this.status,
    required this.host,
    required this.viewerCount,
    required this.totalViews,
    required this.peakViewers,
    required this.likeCount,
    required this.reactionCount,
    required this.commentCount,
    required this.totalWatchTimeSeconds,
    required this.durationSeconds,
    required this.isActive,
    required this.hostUser,
    required this.hostDisplayName,
    required this.viewerState,
    this.startedAt,
    this.endedAt,
    this.coverImage,
    this.thumbnail,
    this.hostAvatar,
  });

  factory LiveStream.initial() {
    return LiveStream(
      id: '',
      title: '',
      roomName: '',
      status: AOSLiveStatus.scheduled,
      host: const LiveHost(userId: '', displayName: ''),
      viewerCount: 0,
      totalViews: 0,
      peakViewers: 0,
      likeCount: 0,
      reactionCount: 0,
      commentCount: 0,
      totalWatchTimeSeconds: 0,
      durationSeconds: 0,
      isActive: false,
      hostUser: '',
      hostDisplayName: '',
      viewerState: LiveViewerState.initial(),
    );
  }

  LiveStream copyWith({
    String? id,
    String? title,
    String? roomName,
    AOSLiveStatus? status,
    LiveHost? host,
    int? viewerCount,
    int? totalViews,
    int? peakViewers,
    int? likeCount,
    int? reactionCount,
    int? commentCount,
    int? totalWatchTimeSeconds,
    int? durationSeconds,
    DateTime? startedAt,
    DateTime? endedAt,
    String? coverImage,
    String? thumbnail,
    bool? isActive,
    String? hostUser,
    String? hostDisplayName,
    String? hostAvatar,
    LiveViewerState? viewerState,
  }) {
    return LiveStream(
      id: id ?? this.id,
      title: title ?? this.title,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      host: host ?? this.host,
      viewerCount: viewerCount ?? this.viewerCount,
      totalViews: totalViews ?? this.totalViews,
      peakViewers: peakViewers ?? this.peakViewers,
      likeCount: likeCount ?? this.likeCount,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      totalWatchTimeSeconds:
          totalWatchTimeSeconds ?? this.totalWatchTimeSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      coverImage: coverImage ?? this.coverImage,
      thumbnail: thumbnail ?? this.thumbnail,
      isActive: isActive ?? this.isActive,
      hostUser: hostUser ?? this.hostUser,
      hostDisplayName: hostDisplayName ?? this.hostDisplayName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      viewerState: viewerState ?? this.viewerState,
    );
  }
}
