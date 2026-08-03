import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';

const Object _unsetConversationField = Object();

class ChatConversation {
  final String id;
  final String user;
  final String displayName;
  final String? avatar;

  final String? lastMessage;
  final DateTime? lastMessageAt;

  final String? lastSender;
  final String? lastSenderDisplayName;
  final String? lastSenderAvatar;

  final DateTime? lastMessageDeliveredAt;
  final DateTime? lastMessageReadAt;

  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.user,
    required this.displayName,
    this.avatar,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSender,
    this.lastSenderDisplayName,
    this.lastSenderAvatar,
    this.lastMessageDeliveredAt,
    this.lastMessageReadAt,
    required this.unreadCount,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: asString(json['id']),
      user: normalizeCanonicalUserId(asString(json['user'])),
      displayName: asString(json['display_name']),
      avatar: asNullableString(json['avatar']),

      lastMessage: asNullableString(json['last_message']),
      lastMessageAt: _parseDateTime(json['last_message_at']),

      lastSender: normalizeCanonicalUserId(
        asNullableString(json['last_sender']),
      ),
      lastSenderDisplayName: asNullableString(json['last_sender_display_name']),
      lastSenderAvatar: asNullableString(json['last_sender_avatar']),

      lastMessageDeliveredAt: _parseDateTime(json['last_message_delivered_at']),
      lastMessageReadAt: _parseDateTime(json['last_message_read_at']),

      unreadCount: asInt(json['unread_count']),
    );
  }

  ChatConversation copyWith({
    String? id,
    String? user,
    String? displayName,
    Object? avatar = _unsetConversationField,
    Object? lastMessage = _unsetConversationField,
    Object? lastMessageAt = _unsetConversationField,
    Object? lastSender = _unsetConversationField,
    Object? lastSenderDisplayName = _unsetConversationField,
    Object? lastSenderAvatar = _unsetConversationField,
    Object? lastMessageDeliveredAt = _unsetConversationField,
    Object? lastMessageReadAt = _unsetConversationField,
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      avatar: identical(avatar, _unsetConversationField)
          ? this.avatar
          : avatar as String?,
      lastMessage: identical(lastMessage, _unsetConversationField)
          ? this.lastMessage
          : lastMessage as String?,
      lastMessageAt: identical(lastMessageAt, _unsetConversationField)
          ? this.lastMessageAt
          : lastMessageAt as DateTime?,
      lastSender: identical(lastSender, _unsetConversationField)
          ? this.lastSender
          : lastSender as String?,
      lastSenderDisplayName:
          identical(lastSenderDisplayName, _unsetConversationField)
          ? this.lastSenderDisplayName
          : lastSenderDisplayName as String?,
      lastSenderAvatar: identical(lastSenderAvatar, _unsetConversationField)
          ? this.lastSenderAvatar
          : lastSenderAvatar as String?,
      lastMessageDeliveredAt:
          identical(lastMessageDeliveredAt, _unsetConversationField)
          ? this.lastMessageDeliveredAt
          : lastMessageDeliveredAt as DateTime?,
      lastMessageReadAt:
          identical(lastMessageReadAt, _unsetConversationField)
          ? this.lastMessageReadAt
          : lastMessageReadAt as DateTime?,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  bool isLastMessageMine(String? authenticatedCanonicalId) {
    final senderId = normalizeCanonicalUserId(lastSender);
    final currentId = normalizeCanonicalUserId(authenticatedCanonicalId);
    return senderId.isNotEmpty && currentId.isNotEmpty && senderId == currentId;
  }

  bool get isLastMessageRead {
    return lastMessageReadAt != null;
  }

  bool get isLastMessageDelivered {
    return lastMessageDeliveredAt != null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    return DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }
}
