import 'package:africaonlinestores/core/navigation/protected_navigation_coordinator.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_destination_parser.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_item.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';

class NotificationNavigationHandler {
  const NotificationNavigationHandler({
    required ProtectedNavigationCoordinator coordinator,
    NotificationDestinationParser parser =
        const NotificationDestinationParser(),
  }) : _coordinator = coordinator,
       _parser = parser;

  final ProtectedNavigationCoordinator _coordinator;
  final NotificationDestinationParser _parser;

  bool handleNotificationTap(NotificationItem notification) {
    final destination = _parser.parse(
      type: notification.type,
      payload: notification.payload,
    );
    if (destination == null) return false;

    return _coordinator.submit(
      sourceKey: 'notification:${notification.id}',
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
