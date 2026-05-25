import 'package:africaonlinestores/features/social/domain/social_friend.dart';

class SocialFriendModel extends SocialFriend {
  const SocialFriendModel({
    required super.user,
    required super.fullName,
    super.userImage,
    super.totalFollowers,
    super.totalFollowing,
    super.isVerified,
    super.followedAt,
    required super.targetUser,
    super.isSelf,
    super.isFollowing,
    super.isFollowedBy,
    super.isFriend,
    super.relationshipStatus,
    super.actionLabel,
    super.followedBackAt,
  });

  factory SocialFriendModel.fromJson(Map<String, dynamic> json) {
    return SocialFriendModel(
      user: _string(json['user']),
      fullName: _string(json['full_name']),
      userImage: _nullableString(json['user_image']),
      totalFollowers: _int(json['total_followers']),
      totalFollowing: _int(json['total_following']),
      isVerified: _bool(json['is_verified']),
      followedAt: _date(json['followed_at']),
      targetUser: _string(json['target_user']),
      isSelf: _bool(json['is_self']),
      isFollowing: _bool(json['is_following']),
      isFollowedBy: _bool(json['is_followed_by']),
      isFriend: _bool(json['is_friend']),
      relationshipStatus: _string(json['relationship_status']),
      actionLabel: _string(json['action_label']),
      followedBackAt: _date(json['followed_back_at']),
    );
  }

  factory SocialFriendModel.fromEntity(SocialFriend friend) {
    return SocialFriendModel(
      user: friend.user,
      fullName: friend.fullName,
      userImage: friend.userImage,
      totalFollowers: friend.totalFollowers,
      totalFollowing: friend.totalFollowing,
      isVerified: friend.isVerified,
      followedAt: friend.followedAt,
      targetUser: friend.targetUser,
      isSelf: friend.isSelf,
      isFollowing: friend.isFollowing,
      isFollowedBy: friend.isFollowedBy,
      isFriend: friend.isFriend,
      relationshipStatus: friend.relationshipStatus,
      actionLabel: friend.actionLabel,
      followedBackAt: friend.followedBackAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'full_name': fullName,
      'user_image': userImage,
      'total_followers': totalFollowers,
      'total_following': totalFollowing,
      'is_verified': isVerified,
      'followed_at': _dateToBackendString(followedAt),
      'target_user': targetUser,
      'is_self': isSelf,
      'is_following': isFollowing,
      'is_followed_by': isFollowedBy,
      'is_friend': isFriend,
      'relationship_status': relationshipStatus,
      'action_label': actionLabel,
      'followed_back_at': _dateToBackendString(followedBackAt),
    };
  }

  static String _string(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String? _nullableString(dynamic value) {
    final clean = value?.toString().trim();

    if (clean == null || clean.isEmpty || clean.toLowerCase() == 'null') {
      return null;
    }

    return clean;
  }

  static int _int(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _bool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;

    final clean = value.toString().trim().toLowerCase();

    return clean == 'true' || clean == '1' || clean == 'yes';
  }

  static DateTime? _date(dynamic value) {
    final clean = value?.toString().trim();

    if (clean == null || clean.isEmpty || clean.toLowerCase() == 'null') {
      return null;
    }

    return DateTime.tryParse(clean);
  }

  static String? _dateToBackendString(DateTime? value) {
    if (value == null) return null;

    return value.toIso8601String();
  }
}
