import 'package:africaonlinestores/features/social/domain/social_relationship.dart';

class SocialRelationshipModel extends SocialRelationship {
  const SocialRelationshipModel({
    required super.targetUser,
    required super.isSelf,
    required super.isFollowing,
    required super.isFollowedBy,
    required super.isFriend,
    required super.relationshipStatus,
    required super.actionLabel,
    super.isBlockedByMe,
    super.hasBlockedMe,
    super.isBlocked,
    super.blockStatus,
    super.status,
    super.targetTotalFollowers,
    super.currentTotalFollowing,
  });

  factory SocialRelationshipModel.fromJson(Map<String, dynamic> json) {
    return SocialRelationshipModel(
      targetUser: _string(json['target_user']),
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
      status: _nullableString(json['status']),
      targetTotalFollowers: _nullableNonNegativeInt(
        json['target_total_followers'],
      ),
      currentTotalFollowing: _nullableNonNegativeInt(
        json['current_total_following'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'target_user': targetUser,
      'is_self': isSelf,
      'is_following': isFollowing,
      'is_followed_by': isFollowedBy,
      'is_friend': isFriend,
      'relationship_status': relationshipStatus,
      'action_label': actionLabel,
      'is_blocked_by_me': isBlockedByMe,
      'has_blocked_me': hasBlockedMe,
      'is_blocked': isBlocked,
      'block_status': blockStatus,
      'status': status,
      'target_total_followers': targetTotalFollowers,
      'current_total_following': currentTotalFollowing,
    };
  }

  static String _string(Object? value) {
    final String clean = value?.toString().trim() ?? '';
    return clean.toLowerCase() == 'null' ? '' : clean;
  }

  static String? _nullableString(Object? value) {
    final String clean = _string(value);
    return clean.isEmpty ? null : clean;
  }

  static int? _nullableNonNegativeInt(Object? value) {
    if (value == null) return null;

    final int? parsed;
    if (value is int) {
      parsed = value;
    } else if (value is num) {
      parsed = value.toInt();
    } else {
      parsed = int.tryParse(value.toString());
    }

    if (parsed == null) return null;
    return parsed < 0 ? 0 : parsed;
  }

  static bool _bool(Object? value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;

    final String clean = value.toString().trim().toLowerCase();
    return clean == 'true' || clean == '1' || clean == 'yes';
  }
}
