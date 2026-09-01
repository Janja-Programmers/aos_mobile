import 'package:flutter/foundation.dart';

@immutable
class LiveCommentReplyContext {
  const LiveCommentReplyContext({
    required this.messageId,
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.isVerified,
    required this.comment,
  });

  final String messageId;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final String comment;

  String get authorLabel {
    final clean = displayName.trim();
    return clean.isNotEmpty ? clean : 'AOS User';
  }
}

@immutable
class LiveComment {
  const LiveComment({
    required this.id,
    required this.liveId,
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.isVerified,
    required this.comment,
    required this.messageKind,
    required this.messageType,
    required this.parentId,
    required this.rootId,
    required this.replyCount,
    required this.replyTo,
    required this.isDeleted,
    required this.createdAt,
  });

  final String id;
  final String liveId;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final String comment;
  final String messageKind;
  final String messageType;
  final String? parentId;
  final String? rootId;
  final int replyCount;
  final LiveCommentReplyContext? replyTo;
  final bool isDeleted;
  final DateTime createdAt;

  bool get isSystem => messageKind == 'system' || messageType == 'system';
  bool get isComment => messageKind == 'comment';
  bool get isReply => isComment && messageType == 'reply';
  bool get canOpenProfile => userId.trim().toUpperCase().startsWith('ACC-');

  String get authorLabel {
    final clean = displayName.trim();
    if (clean.isNotEmpty) return clean;
    return isSystem ? 'AOS' : 'AOS User';
  }

  LiveComment copyWith({
    String? id,
    String? liveId,
    String? userId,
    String? displayName,
    String? avatarUrl,
    bool clearAvatar = false,
    bool? isVerified,
    String? comment,
    String? messageKind,
    String? messageType,
    String? parentId,
    bool clearParent = false,
    String? rootId,
    bool clearRoot = false,
    int? replyCount,
    LiveCommentReplyContext? replyTo,
    bool clearReplyTo = false,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return LiveComment(
      id: id ?? this.id,
      liveId: liveId ?? this.liveId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: clearAvatar ? null : avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      comment: comment ?? this.comment,
      messageKind: messageKind ?? this.messageKind,
      messageType: messageType ?? this.messageType,
      parentId: clearParent ? null : parentId ?? this.parentId,
      rootId: clearRoot ? null : rootId ?? this.rootId,
      replyCount: replyCount ?? this.replyCount,
      replyTo: clearReplyTo ? null : replyTo ?? this.replyTo,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
