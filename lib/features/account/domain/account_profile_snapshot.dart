import 'package:flutter/foundation.dart';

@immutable
class AccountProfileSnapshot {
  const AccountProfileSnapshot({
    required this.user,
    required this.fullName,
    required this.email,
    required this.bio,
    required this.userImage,
    required this.profileImageMediaId,
    required this.isDeleted,
    required this.isLive,
    required this.liveId,
    required this.liveStatus,
    required this.liveTitle,
    required this.liveCoverImage,
    required this.liveViewerCount,
    required this.liveViewerCountDisplay,
    required this.totalFollowers,
    required this.totalFollowersDisplay,
    required this.totalFollowing,
    required this.totalFollowingDisplay,
    required this.totalFriends,
    required this.totalFriendsDisplay,
    required this.totalShortLikes,
    required this.totalShortLikesDisplay,
    required this.isVerified,
    required this.canEdit,
    required this.isSelf,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isFriend,
    required this.relationshipStatus,
    required this.actionLabel,
    required this.isBlockedByMe,
    required this.hasBlockedMe,
    required this.isBlocked,
    required this.blockStatus,
  });

  final String user;
  final String fullName;
  final String? email;
  final String bio;
  final String? userImage;
  final String? profileImageMediaId;
  final bool isDeleted;
  final bool isLive;
  final String? liveId;
  final String? liveStatus;
  final String? liveTitle;
  final String? liveCoverImage;
  final int liveViewerCount;
  final String liveViewerCountDisplay;
  final int totalFollowers;
  final String totalFollowersDisplay;
  final int totalFollowing;
  final String totalFollowingDisplay;
  final int totalFriends;
  final String totalFriendsDisplay;
  final int totalShortLikes;
  final String totalShortLikesDisplay;
  final bool isVerified;
  final bool canEdit;
  final bool isSelf;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isFriend;
  final String relationshipStatus;
  final String actionLabel;
  final bool isBlockedByMe;
  final bool hasBlockedMe;
  final bool isBlocked;
  final String blockStatus;

  bool get hasLiveRoom => isLive && (liveId?.isNotEmpty ?? false);

  bool get allowsSocialInteraction =>
      !isDeleted && !isBlocked && !isBlockedByMe && !hasBlockedMe;

  factory AccountProfileSnapshot.fromJson(Map<String, dynamic> json) {
    return AccountProfileSnapshot(
      user: _firstString(<Object?>[json['account_id'], json['user']]),
      fullName: _firstString(<Object?>[
        json['display_name'],
        json['full_name'],
      ]),
      email: _nullableString(json['email']),
      bio: _string(json['bio']),
      userImage: _firstNullableString(<Object?>[
        json['avatar'],
        json['user_image'],
      ]),
      profileImageMediaId: _nullableString(
        json['profile_image_media_id'] ?? json['profile_image_media'],
      ),
      isDeleted: _bool(json['is_deleted']),
      isLive: _bool(json['is_live']),
      liveId: _nullableString(json['live_id']),
      liveStatus: _nullableString(json['live_status']),
      liveTitle: _nullableString(json['live_title']),
      liveCoverImage: _nullableString(json['live_cover_image']),
      liveViewerCount: _nonNegativeInt(json['live_viewer_count']),
      liveViewerCountDisplay: _display(
        json['live_viewer_count_display'],
        json['live_viewer_count'],
      ),
      totalFollowers: _nonNegativeInt(json['total_followers']),
      totalFollowersDisplay: _display(
        json['total_followers_display'],
        json['total_followers'],
      ),
      totalFollowing: _nonNegativeInt(json['total_following']),
      totalFollowingDisplay: _display(
        json['total_following_display'],
        json['total_following'],
      ),
      totalFriends: _nonNegativeInt(json['total_friends']),
      totalFriendsDisplay: _display(
        json['total_friends_display'],
        json['total_friends'],
      ),
      totalShortLikes: _nonNegativeInt(json['total_short_likes']),
      totalShortLikesDisplay: _display(
        json['total_short_likes_display'],
        json['total_short_likes'],
      ),
      isVerified: _bool(json['is_verified']),
      canEdit: _bool(json['can_edit']),
      isSelf: _bool(json['is_self']),
      isFollowing: _bool(json['is_following']),
      isFollowedBy: _bool(json['is_followed_by']),
      isFriend: _bool(json['is_friend']),
      relationshipStatus: _string(json['relationship_status']),
      actionLabel: _string(json['action_label']),
      isBlockedByMe: _bool(json['is_blocked_by_me']),
      hasBlockedMe: _bool(json['has_blocked_me']),
      isBlocked: _bool(json['is_blocked']),
      blockStatus: _string(json['block_status']),
    );
  }

  static String _display(Object? display, Object? raw) {
    final String clean = _string(display);
    return clean.isNotEmpty ? clean : _nonNegativeInt(raw).toString();
  }

  static String _firstString(Iterable<Object?> values) {
    for (final value in values) {
      final clean = _string(value);
      if (clean.isNotEmpty) return clean;
    }
    return '';
  }

  static String? _firstNullableString(Iterable<Object?> values) {
    final clean = _firstString(values);
    return clean.isEmpty ? null : clean;
  }

  static String _string(Object? value) {
    final String clean = value?.toString().trim() ?? '';
    return clean.toLowerCase() == 'null' ? '' : clean;
  }

  static String? _nullableString(Object? value) {
    final String clean = _string(value);
    return clean.isEmpty ? null : clean;
  }

  static int _nonNegativeInt(Object? value) {
    final int parsed;
    if (value is int) {
      parsed = value;
    } else if (value is num) {
      parsed = value.toInt();
    } else {
      parsed = int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return parsed < 0 ? 0 : parsed;
  }

  static bool _bool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final String clean = value?.toString().trim().toLowerCase() ?? '';
    return clean == '1' ||
        clean == 'true' ||
        clean == 'yes' ||
        clean == 'approved' ||
        clean == 'verified';
  }
}
