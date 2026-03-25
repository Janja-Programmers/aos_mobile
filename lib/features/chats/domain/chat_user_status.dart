class ChatUserStatus {
  final String user;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUserStatus({required this.user, required this.isOnline, this.lastSeen});

  factory ChatUserStatus.fromJson(Map<String, dynamic> json) {
    return ChatUserStatus(
      user: json['user'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
    );
  }
}
