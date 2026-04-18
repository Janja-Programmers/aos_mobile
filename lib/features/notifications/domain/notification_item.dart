import 'dart:convert';

import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';

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
      isRead: _parseBool(json['is_read']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      payload: NotificationPayload.fromJson(_parsePayload(json['payload'])),
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

Map<String, dynamic>? _parsePayload(dynamic raw) {
  try {
    if (raw == null) return null;

    // ✅ Already a map
    if (raw is Map<String, dynamic>) {
      return raw;
    }

    // ✅ String → decode JSON
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    return null;
  } catch (_) {
    return null;
  }
}
