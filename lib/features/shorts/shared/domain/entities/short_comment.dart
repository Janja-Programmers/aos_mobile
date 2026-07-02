import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:equatable/equatable.dart';

class ShortComment extends Equatable {
  final CommentId id;
  final ShortId shortId;

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

  const ShortComment({
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

  String get authorName {
    final name = displayName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    final user = userId.trim();

    if (user.isNotEmpty) {
      return user;
    }

    return 'User';
  }

  ShortComment copyWith({
    CommentId? id,
    ShortId? shortId,
    String? userId,
    String? displayName,
    String? avatar,
    String? comment,
    String? parentId,
    String? rootId,
    int? replyCount,
    int? likeCount,
    bool? isLiked,
    bool? isOwner,
    bool? canDelete,
    bool? isDeleted,
    String? createdAt,
  }) {
    return ShortComment(
      id: id ?? this.id,
      shortId: shortId ?? this.shortId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      comment: comment ?? this.comment,
      parentId: parentId ?? this.parentId,
      rootId: rootId ?? this.rootId,
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isOwner: isOwner ?? this.isOwner,
      canDelete: canDelete ?? this.canDelete,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shortId,
    userId,
    displayName,
    avatar,
    comment,
    parentId,
    rootId,
    replyCount,
    likeCount,
    isLiked,
    isOwner,
    canDelete,
    isDeleted,
    createdAt,
  ];
}
