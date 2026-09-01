import 'package:africaonlinestores/core/utils/json_utils.dart';

class LiveCommentReplyContextModel {
  const LiveCommentReplyContextModel({
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

  factory LiveCommentReplyContextModel.fromJson(Map<String, dynamic> json) {
    return LiveCommentReplyContextModel(
      messageId: _firstText(<Object?>[json['message_id'], json['id']]),
      userId: _firstText(<Object?>[json['user'], json['user_id']]),
      displayName: _firstText(<Object?>[
        json['display_name'],
        json['full_name'],
      ]),
      avatarUrl: asNullableString(json['avatar'] ?? json['avatar_url']),
      isVerified: _bool(json['is_verified']),
      comment: _firstText(<Object?>[json['content'], json['comment']]),
    );
  }
}

class LiveCommentModel {
  const LiveCommentModel({
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
  final LiveCommentReplyContextModel? replyTo;
  final bool isDeleted;
  final String createdAt;

  factory LiveCommentModel.fromJson(Map<String, dynamic> json) {
    final replyToMap = asJsonMap(json['reply_to']);
    return LiveCommentModel(
      id: _firstText(<Object?>[json['message_id'], json['id'], json['name']]),
      liveId: _firstText(<Object?>[json['live_id'], json['live_stream']]),
      userId: _firstText(<Object?>[
        json['user_id'],
        json['user'],
        json['sender'],
      ]),
      displayName: _firstText(<Object?>[
        json['display_name'],
        json['full_name'],
      ]),
      avatarUrl: asNullableString(
        json['avatar'] ?? json['avatar_url'] ?? json['user_image'],
      ),
      isVerified: _bool(json['is_verified']),
      comment: _firstText(<Object?>[json['content'], json['comment']]),
      messageKind: _firstText(<Object?>[json['message_kind'], json['kind']]),
      messageType: _firstText(<Object?>[json['message_type']]),
      parentId: asNullableString(
        json['parent_message'] ?? json['parent_id'] ?? json['parent_comment'],
      ),
      rootId: asNullableString(
        json['root_message'] ?? json['root_id'] ?? json['root_comment'],
      ),
      replyCount: _int(json['reply_count']),
      replyTo: replyToMap.isEmpty
          ? null
          : LiveCommentReplyContextModel.fromJson(replyToMap),
      isDeleted:
          _bool(json['is_deleted']) ||
          json['status']?.toString().trim().toLowerCase() == 'deleted',
      createdAt: _firstText(<Object?>[
        json['created_at'],
        json['creation'],
        DateTime.now().toIso8601String(),
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'live_id': liveId,
      'user_id': userId,
      'display_name': displayName,
      'avatar': avatarUrl,
      'is_verified': isVerified,
      'comment': comment,
      'message_kind': messageKind,
      'message_type': messageType,
      'parent_id': parentId,
      'root_id': rootId,
      'reply_count': replyCount,
      'is_deleted': isDeleted,
      'created_at': createdAt,
    };
  }
}

String _firstText(Iterable<Object?> values) {
  for (final value in values) {
    final clean = value?.toString().trim() ?? '';
    if (clean.isNotEmpty && clean.toLowerCase() != 'null') return clean;
  }
  return '';
}

bool _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final clean = value?.toString().trim().toLowerCase() ?? '';
  return clean == '1' || clean == 'true' || clean == 'yes';
}

int _int(Object? value) {
  if (value is int) return value < 0 ? 0 : value;
  if (value is num) {
    final parsed = value.toInt();
    if (parsed < 0) return 0;
    return parsed;
  }
  final parsed = int.tryParse(value?.toString() ?? '') ?? 0;
  return parsed < 0 ? 0 : parsed;
}
