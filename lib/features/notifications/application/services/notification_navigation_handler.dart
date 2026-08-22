import 'package:africaonlinestores/core/navigation/protected_navigation_coordinator.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_destination_parser.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';

class NotificationNavigationHandler {
  NotificationNavigationHandler({
    required ProtectedNavigationCoordinator coordinator,
    NotificationDestinationParser parser =
        const NotificationDestinationParser(),
  }) : _coordinator = coordinator,
       _parser = parser;

  final ProtectedNavigationCoordinator _coordinator;
  final NotificationDestinationParser _parser;

  static const Duration _tapDebounce = Duration(milliseconds: 700);
  String? _lastTappedNotificationId;
  DateTime? _lastTapAt;
  int _tapSerial = 0;

  bool handleNotificationTap(NotificationItem notification) {
    final payload = _payloadWithNotificationActor(notification);
    final destination = _parser.parse(
      type: notification.type,
      payload: payload,
    );
    if (destination == null) return false;

    final notificationId = notification.id.trim();
    final now = DateTime.now();
    final previousTapAt = _lastTapAt;
    if (_lastTappedNotificationId == notificationId &&
        previousTapAt != null &&
        now.difference(previousTapAt) < _tapDebounce) {
      return true;
    }

    _lastTappedNotificationId = notificationId;
    _lastTapAt = now;
    final tapSerial = ++_tapSerial;

    return _coordinator.submit(
      sourceKey: 'notification:$notificationId:tap:$tapSerial',
      destination: destination,
    );
  }

  bool handlePayloadTap(Map<String, dynamic> payload) {
    final NotificationPayload parsedPayload = NotificationPayload.fromJson(
      payload,
    );
    final NotificationType type = NotificationTypeX.fromBackendValue(
      _read(payload, 'event') ??
          _read(payload, 'notification_type') ??
          _read(payload, 'type') ??
          parsedPayload.event,
    );
    final destination = _parser.parse(type: type, payload: parsedPayload);
    if (destination == null) return false;

    final String sourceKey = _boundedSourceKey(
      _read(payload, 'message_id') ?? _read(payload, 'notification_id'),
      fallback: 'payload:${type.value}:${destination.signature}',
    );

    return _coordinator.submit(sourceKey: sourceKey, destination: destination);
  }
}

NotificationPayload _payloadWithNotificationActor(
  NotificationItem notification,
) {
  final payload = notification.payload;
  final actorId = notification.actorId?.trim();
  final actorName = notification.actorName?.trim();
  final hasDisplayName =
      actorName != null &&
      actorName.isNotEmpty &&
      (actorId == null || actorName.toLowerCase() != actorId.toLowerCase());

  return NotificationPayload.fromJson(<String, dynamic>{
    ...payload.toJson(),
    if (payload.userId == null && actorId != null && actorId.isNotEmpty)
      'actor_id': actorId,
    if (payload.actorName == null &&
        payload.otherUserName == null &&
        hasDisplayName)
      'actor_name': actorName,
    if (payload.actorAvatar == null && notification.actorAvatar != null)
      'actor_avatar': notification.actorAvatar,
  });
}

String? _read(Map<String, dynamic> json, String key) {
  final String? value = json[key]?.toString().trim();
  if (value == null || value.isEmpty || value.toLowerCase() == 'null') {
    return null;
  }
  return value;
}

String _boundedSourceKey(String? value, {required String fallback}) {
  final String? clean = value?.trim();
  if (clean == null || clean.isEmpty || clean.length > 200) return fallback;
  return clean;
}
