import 'package:africaonlinestores/core/utils/json_utils.dart';

class ChatUserStatus {
  final String user;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUserStatus({required this.user, required this.isOnline, this.lastSeen});

  factory ChatUserStatus.fromJson(Map<String, dynamic> json) {
    return ChatUserStatus(
      user: asString(json['user']),
      isOnline: asBool(json['is_online']),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(asString(json['last_seen']))
          : null,
    );
  }
}
