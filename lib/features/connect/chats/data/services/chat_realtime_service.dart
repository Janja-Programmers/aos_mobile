import 'package:africaonlinestores/core/realtime/realtime_event_type.dart';
import 'package:africaonlinestores/core/realtime/realtime_service.dart';

class ChatRealtimeService {
  final RealtimeService realtime;

  ChatRealtimeService(this.realtime);

  // -----------------------------
  // Streams (Filtered from core)
  // -----------------------------
  Stream<dynamic> get messages => realtime.events
      .where((e) => e.type == RealtimeEventType.chatNewMessage)
      .map((e) => e.data);

  Stream<dynamic> get typing => realtime.events
      .where((e) => e.type == RealtimeEventType.chatTyping)
      .map((e) => e.data);

  Stream<dynamic> get presence => realtime.events
      .where((e) => e.type == RealtimeEventType.presenceUpdate)
      .map((e) => e.data);

  Stream<dynamic> get messageStatus => realtime.events
      .where((e) => e.type == RealtimeEventType.aosMessageStatus)
      .map((e) => e.data);

  Stream<dynamic> get messageEdited => realtime.events
      .where((e) => e.type == RealtimeEventType.aosMessageEdited)
      .map((e) => e.data);

  Stream<dynamic> get messagesDeleted => realtime.events
      .where((e) => e.type == RealtimeEventType.aosMessagesDeleted)
      .map((e) => e.data);

  Stream<dynamic> get messageReactionUpdated => realtime.events
      .where((e) => e.type == RealtimeEventType.aosMessageReactionUpdated)
      .map((e) => e.data);
}
