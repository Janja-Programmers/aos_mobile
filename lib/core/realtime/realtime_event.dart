import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';

class RealtimeEvent {
  RealtimeEvent({required this.type, required this.data, this.eventName});

  final RealtimeEventType type;
  final Object? data;

  /// Raw Socket.IO event name. This preserves forward-compatible recipient
  /// scoped transports such as `aos_notification_center` without forcing an
  /// unrelated business-domain enum expansion.
  final String? eventName;
}
