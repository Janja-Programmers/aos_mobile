import 'dart:convert';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';

class NotificationItem {
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

  bool get hasCanonicalPersistentId =>
      id.isNotEmpty &&
      !id.startsWith('push_') &&
      !id.startsWith('notification_');

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
    final Map<String, dynamic>? payloadMap = _parsePayload(json['payload']);
    final NotificationPayload payload = NotificationPayload.fromJson(
      payloadMap,
    );

    final String? typeValue =
        _read(json, 'type') ??
        payload.event ??
        payload.notificationType ??
        _read(payloadMap, 'event') ??
        _read(payloadMap, 'notification_type') ??
        _read(payloadMap, 'type');
    final NotificationType type = NotificationTypeX.fromBackendValue(typeValue);

    final String? actorId =
        _read(json, 'actor') ??
        _read(json, 'actor_id') ??
        _read(payloadMap, 'actor') ??
        _read(payloadMap, 'sender_account_id') ??
        _read(payloadMap, 'caller_account_id') ??
        _read(payloadMap, 'follower') ??
        _read(payloadMap, 'host_user') ??
        payload.userId;

    return NotificationItem(
      id: _resolvePersistentId(json, payloadMap),
      type: type,
      title: _read(json, 'title') ?? _fallbackTitleForType(type),
      body: _read(json, 'body') ?? '',
      actorId: actorId,
      actorName:
          _read(json, 'actor_display_name') ??
          _read(json, 'actor_name') ??
          _read(payloadMap, 'actor_name') ??
          actorId,
      actorAvatar: normalizeMediaUrl(
        _read(json, 'actor_avatar') ?? _read(payloadMap, 'actor_avatar'),
      ),
      isRead: _parseBool(json['is_read']),
      createdAt:
          _parseDate(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      payload: payload,
    );
  }

  factory NotificationItem.fromPushData({
    required Map<String, dynamic> data,
    String? messageId,
    String? title,
    String? body,
    DateTime? sentTime,
  }) {
    final NotificationPayload payload = NotificationPayload.fromJson(data);
    final String? eventOrType =
        _read(data, 'event') ??
        _read(data, 'notification_type') ??
        _read(data, 'type') ??
        payload.event ??
        payload.notificationType;
    final NotificationType type = NotificationTypeX.fromBackendValue(
      eventOrType,
    );

    final String? actorId =
        _read(data, 'actor') ??
        _read(data, 'actor_id') ??
        _read(data, 'sender_account_id') ??
        _read(data, 'caller_account_id') ??
        _read(data, 'sender') ??
        _read(data, 'caller') ??
        _read(data, 'follower') ??
        _read(data, 'host_user') ??
        payload.userId;

    final DateTime now = DateTime.now();
    final String? persistentId = _read(data, 'notification_id');
    final String id =
        persistentId ??
        'push_${messageId ?? eventOrType ?? type.value}_${now.microsecondsSinceEpoch}';

    return NotificationItem(
      id: id,
      type: type,
      title: title ?? _read(data, 'title') ?? _fallbackTitleForType(type),
      body: body ?? _read(data, 'body') ?? '',
      actorId: actorId,
      actorName:
          _read(data, 'actor_display_name') ??
          _read(data, 'actor_name') ??
          _read(data, 'sender_display_name') ??
          _read(data, 'caller_display_name') ??
          actorId,
      actorAvatar: normalizeMediaUrl(
        _read(data, 'actor_avatar') ??
            _read(data, 'sender_avatar') ??
            _read(data, 'caller_avatar'),
      ),
      isRead: false,
      createdAt: sentTime ?? now,
      payload: payload,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.value,
      'title': title,
      'body': body,
      'actor': actorId,
      'actor_display_name': actorName,
      'actor_avatar': actorAvatar,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'payload': payload.toJson(),
    };
  }
}

String? _read(Map<String, dynamic>? json, String key) {
  if (json == null) return null;
  final String? text = json[key]?.toString().trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

String _resolvePersistentId(
  Map<String, dynamic> json,
  Map<String, dynamic>? payload,
) {
  return _read(json, 'id') ??
      _read(json, 'name') ??
      _read(json, 'notification_id') ??
      _read(payload, 'notification_id') ??
      '';
}

bool _parseBool(Object? value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final String normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return false;
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final String text = value.toString().trim();
  return text.isEmpty ? null : DateTime.tryParse(text);
}

Map<String, dynamic>? _parsePayload(Object? raw) {
  try {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return asJsonMap(raw);
    if (raw is Map<Object?, Object?>) {
      return raw.map<String, dynamic>(
        (Object? key, Object? value) =>
            MapEntry<String, dynamic>(key.toString(), value),
      );
    }
    if (raw is String && raw.trim().isNotEmpty) {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return asJsonMap(decoded);
      if (decoded is Map<Object?, Object?>) {
        return decoded.map<String, dynamic>(
          (Object? key, Object? value) =>
              MapEntry<String, dynamic>(key.toString(), value),
        );
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

String _fallbackTitleForType(NotificationType type) {
  return switch (type) {
    NotificationType.message => 'New Message',
    NotificationType.incomingCall => 'Incoming Call',
    NotificationType.missedCall => 'Missed Call',
    NotificationType.callRejected => 'Call Rejected',
    NotificationType.callEnded => 'Call Ended',
    NotificationType.adApproved => 'Ad Approved',
    NotificationType.adRejected => 'Ad Rejected',
    NotificationType.adExpired => 'Ad Expired',
    NotificationType.reviewReceived => 'New Review',
    NotificationType.reviewApproved => 'Review Approved',
    NotificationType.reviewRejected => 'Review Rejected',
    NotificationType.verificationApproved => 'Verification Approved',
    NotificationType.verificationRejected => 'Verification Rejected',
    NotificationType.liveStarted => 'Live Started',
    NotificationType.follow => 'New Follower',
    NotificationType.newShort => 'New Short',
    NotificationType.shortLike => 'New Like',
    NotificationType.shortComment => 'New Comment',
    NotificationType.shortMention => 'New Mention',
    NotificationType.commentReply => 'New Reply',
    NotificationType.unknown => 'Notification',
  };
}
