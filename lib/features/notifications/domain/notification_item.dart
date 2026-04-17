import 'notification_payload.dart';
import 'notification_type.dart';

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? actorId;
  final String? actorName;
  final String? actorAvatar;
  final bool isRead;
  final DateTime createdAt;
  final NotificationPayload payload;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actorId,
    this.actorName,
    this.actorAvatar,
    required this.isRead,
    required this.createdAt,
    required this.payload,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      actorId: actorId,
      actorName: actorName,
      actorAvatar: actorAvatar,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      payload: payload,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: NotificationTypeX.fromString(json['type']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      actorId: json['actor']?.toString(),
      actorName: json['actor_name'],
      actorAvatar: json['actor_avatar'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      payload: NotificationPayload.fromJson(json['payload']),
    );
  }
}
