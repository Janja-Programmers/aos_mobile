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
      id: json['id'] as String,
      user: json['user'] as String,
      displayName: json['display_name'] as String,
      avatar: json['avatar'] as String?,

      lastMessage: json['last_message'] as String?,
      lastMessageAt: _parseDateTime(json['last_message_at']),

      lastSender: json['last_sender'] as String?,
      lastSenderDisplayName: json['last_sender_display_name'] as String?,
      lastSenderAvatar: json['last_sender_avatar'] as String?,

      lastMessageDeliveredAt: _parseDateTime(json['last_message_delivered_at']),
      lastMessageReadAt: _parseDateTime(json['last_message_read_at']),

      unreadCount: json['unread_count'] ?? 0,
    );
  }

  ChatConversation copyWith({
    String? id,
    String? user,
    String? displayName,
    String? avatar,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastSender,
    String? lastSenderDisplayName,
    String? lastSenderAvatar,
    DateTime? lastMessageDeliveredAt,
    DateTime? lastMessageReadAt,
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastSender: lastSender ?? this.lastSender,
      lastSenderDisplayName:
          lastSenderDisplayName ?? this.lastSenderDisplayName,
      lastSenderAvatar: lastSenderAvatar ?? this.lastSenderAvatar,
      lastMessageDeliveredAt:
          lastMessageDeliveredAt ?? this.lastMessageDeliveredAt,
      lastMessageReadAt: lastMessageReadAt ?? this.lastMessageReadAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  bool isLastMessageMine(String currentUserEmail) {
    return lastSender != null && lastSender == currentUserEmail;
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
