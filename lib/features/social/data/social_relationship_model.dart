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
      status: _nullableString(json['status']),
      targetTotalFollowers: _nullableInt(json['target_total_followers']),
      currentTotalFollowing: _nullableInt(json['current_total_following']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_user': targetUser,
      'is_self': isSelf,
      'is_following': isFollowing,
      'is_followed_by': isFollowedBy,
      'is_friend': isFriend,
      'relationship_status': relationshipStatus,
      'action_label': actionLabel,
      'status': status,
      'target_total_followers': targetTotalFollowers,
      'current_total_following': currentTotalFollowing,
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

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString());
  }

  static bool _bool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;

    final clean = value.toString().trim().toLowerCase();

    return clean == 'true' || clean == '1' || clean == 'yes';
  }
}
