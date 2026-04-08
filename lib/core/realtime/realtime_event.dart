import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';

class RealtimeEvent {
  final RealtimeEventType type;
  final dynamic data;

  RealtimeEvent({required this.type, required this.data});
}
