class ChatConversation {
  final String id;
  final String user;
  final String displayName;
  final String? avatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.user,
    required this.displayName,
    this.avatar,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      user: json['user'],
      displayName: json['display_name'],
      avatar: json['avatar'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
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
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
