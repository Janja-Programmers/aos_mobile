import 'dart:convert';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';

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

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    bool? isRead,
    DateTime? createdAt,
    NotificationPayload? payload,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final payloadMap = _parsePayload(json['payload']);
    final payload = NotificationPayload.fromJson(payloadMap);

    final typeValue =
        _read(json, 'type') ??
        payload.event ??
        payload.notificationType ??
        _read(payloadMap, 'event') ??
        _read(payloadMap, 'notification_type') ??
        _read(payloadMap, 'type');

    final type = NotificationTypeX.fromBackendValue(typeValue);

    final actorId =
        _read(json, 'actor_id') ??
        _read(json, 'actor') ??
        payload.userId ??
        _read(payloadMap, 'actor') ??
        _read(payloadMap, 'sender') ??
        _read(payloadMap, 'caller') ??
        _read(payloadMap, 'follower') ??
        _read(payloadMap, 'host_user');

    return NotificationItem(
      id: _resolveId(json, payloadMap),
      type: type,
      title: _read(json, 'title') ?? _fallbackTitleForType(type),
      body: _read(json, 'body') ?? '',
      actorId: actorId,
      actorName:
          _read(json, 'actor_name') ??
          _read(payloadMap, 'actor_name') ??
          actorId,
      actorAvatar:
          _read(json, 'actor_avatar') ?? _read(payloadMap, 'actor_avatar'),
      isRead: _parseBool(json['is_read']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      payload: payload,
    );
  }

  /// Useful when creating NotificationItem from FCM RemoteMessage.data.
  factory NotificationItem.fromPushData({
    required Map<String, dynamic> data,
    String? messageId,
    String? title,
    String? body,
    DateTime? sentTime,
  }) {
    final payload = NotificationPayload.fromJson(data);

    final eventOrType =
        _read(data, 'event') ??
        _read(data, 'notification_type') ??
        _read(data, 'type') ??
        payload.event ??
        payload.notificationType;

    final type = NotificationTypeX.fromBackendValue(eventOrType);

    final actorId =
        _read(data, 'actor_id') ??
        _read(data, 'actor') ??
        _read(data, 'sender') ??
        _read(data, 'caller') ??
        _read(data, 'follower') ??
        _read(data, 'host_user') ??
        payload.userId;

    final now = DateTime.now();

    return NotificationItem(
      id:
          _read(data, 'notification_id') ??
          messageId ??
          'push_${eventOrType ?? type.value}_${now.microsecondsSinceEpoch}',
      type: type,
      title: title ?? _read(data, 'title') ?? _fallbackTitleForType(type),
      body: body ?? _read(data, 'body') ?? '',
      actorId: actorId,
      actorName:
          _read(data, 'actor_name') ??
          _read(data, 'sender_display_name') ??
          _read(data, 'caller_display_name') ??
          actorId,
      actorAvatar:
          _read(data, 'actor_avatar') ??
          _read(data, 'sender_avatar') ??
          _read(data, 'caller_avatar'),
      isRead: false,
      createdAt: sentTime ?? now,
      payload: payload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'body': body,
      'actor': actorId,
      'actor_name': actorName,
      'actor_avatar': actorAvatar,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'payload': payload.toJson(),
    };
  }
}

String? _read(Map<String, dynamic>? json, String key) {
  if (json == null) return null;

  final value = json[key];
  final text = value?.toString().trim();

  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }

  return text;
}

String _resolveId(Map<String, dynamic> json, Map<String, dynamic>? payload) {
  return _read(json, 'id') ??
      _read(json, 'name') ??
      _read(json, 'notification_id') ??
      _read(payload, 'notification_id') ??
      'notification_${DateTime.now().microsecondsSinceEpoch}';
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  return false;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) return value;

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}

Map<String, dynamic>? _parsePayload(dynamic raw) {
  try {
    if (raw == null) return null;

    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }

    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }

    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }

      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    return null;
  } catch (_) {
    return null;
  }
}

String _fallbackTitleForType(NotificationType type) {
  switch (type) {
    case NotificationType.message:
      return 'New Message';
    case NotificationType.incomingCall:
      return 'Incoming Call';
    case NotificationType.missedCall:
      return 'Missed Call';
    case NotificationType.callRejected:
      return 'Call Rejected';
    case NotificationType.callEnded:
      return 'Call Ended';
    case NotificationType.adApproved:
      return 'Ad Approved';
    case NotificationType.adRejected:
      return 'Ad Rejected';
    case NotificationType.adExpired:
      return 'Ad Expired';
    case NotificationType.verificationApproved:
      return 'Verification Approved';
    case NotificationType.verificationRejected:
      return 'Verification Rejected';
    case NotificationType.liveStarted:
      return 'Live Started';
    case NotificationType.follow:
      return 'New Follower';
    case NotificationType.newShort:
      return 'New Short';
    case NotificationType.shortLike:
      return 'New Like';
    case NotificationType.shortComment:
      return 'New Comment';
    case NotificationType.commentReply:
      return 'New Reply';
    case NotificationType.unknown:
      return 'Notification';
  }
}
