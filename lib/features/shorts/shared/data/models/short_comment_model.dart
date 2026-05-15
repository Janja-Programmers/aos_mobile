class ShortCommentModel {
  final String id;
  final String shortId;

  final String userId;
  final String? displayName;
  final String? avatar;

  final String comment;
  final String? parentId;
  final String? rootId;

  final int replyCount;
  final int likeCount;

  final bool isLiked;
  final bool isOwner;
  final bool canDelete;
  final bool isDeleted;

  final String createdAt;

  const ShortCommentModel({
    required this.id,
    required this.shortId,
    required this.userId,
    this.displayName,
    this.avatar,
    required this.comment,
    this.parentId,
    this.rootId,
    required this.replyCount,
    required this.likeCount,
    required this.isLiked,
    required this.isOwner,
    required this.canDelete,
    required this.isDeleted,
    required this.createdAt,
  });

  factory ShortCommentModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    final creatorRaw = json['creator'];
    final authorRaw = json['author'];

    final userMap = userRaw is Map<String, dynamic> ? userRaw : null;
    final creatorMap = creatorRaw is Map<String, dynamic> ? creatorRaw : null;
    final authorMap = authorRaw is Map<String, dynamic> ? authorRaw : null;

    final userId =
        json['user_id']?.toString() ??
        userMap?['user']?.toString() ??
        creatorMap?['user']?.toString() ??
        authorMap?['user']?.toString() ??
        json['user']?.toString() ??
        json['owner']?.toString() ??
        json['created_by']?.toString() ??
        '';

    final displayName =
        json['display_name']?.toString() ??
        json['user_display_name']?.toString() ??
        json['author_name']?.toString() ??
        json['full_name']?.toString() ??
        json['user_full_name']?.toString() ??
        json['owner_name']?.toString() ??
        userMap?['display_name']?.toString() ??
        userMap?['full_name']?.toString() ??
        userMap?['name']?.toString() ??
        creatorMap?['display_name']?.toString() ??
        creatorMap?['full_name']?.toString() ??
        creatorMap?['name']?.toString() ??
        authorMap?['display_name']?.toString() ??
        authorMap?['full_name']?.toString() ??
        authorMap?['name']?.toString();

    final avatar =
        json['avatar']?.toString() ??
        json['user_avatar']?.toString() ??
        json['user_image']?.toString() ??
        json['owner_image']?.toString() ??
        userMap?['avatar']?.toString() ??
        userMap?['user_image']?.toString() ??
        creatorMap?['avatar']?.toString() ??
        creatorMap?['user_image']?.toString() ??
        authorMap?['avatar']?.toString() ??
        authorMap?['user_image']?.toString();

    return ShortCommentModel(
      id:
          json['id']?.toString() ??
          json['name']?.toString() ??
          json['comment_id']?.toString() ??
          '',
      shortId: json['short_id']?.toString() ?? json['short']?.toString() ?? '',
      userId: userId,
      displayName: displayName,
      avatar: avatar,
      comment:
          json['comment']?.toString() ??
          json['content']?.toString() ??
          json['text']?.toString() ??
          '',
      parentId:
          json['parent_id']?.toString() ??
          json['parent_comment_id']?.toString(),
      rootId:
          json['root_id']?.toString() ?? json['root_comment_id']?.toString(),
      replyCount: _toInt(json['reply_count']),
      likeCount: _toInt(json['like_count']),
      isLiked: _toBool(json['is_liked'] ?? json['liked']),
      isOwner: _toBool(json['is_owner']),
      canDelete: _toBool(json['can_delete']),
      isDeleted: _toBool(json['is_deleted']),
      createdAt:
          json['created_at']?.toString() ?? json['creation']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final raw = value?.toString().trim().toLowerCase();

    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
