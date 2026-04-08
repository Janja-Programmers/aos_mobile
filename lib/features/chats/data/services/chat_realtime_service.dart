import 'package:africaonlinestores/core/utils/logger.dart';
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
      .map((e) {
        appLogger.i('📩 Chat message received: ${e.data}');
        return e.data;
      });

  Stream<dynamic> get typing => realtime.events
      .where((e) => e.type == RealtimeEventType.chatTyping)
      .map((e) {
        appLogger.i('⌨️ Typing event: ${e.data}');
        return e.data;
      });

  Stream<dynamic> get presence => realtime.events
      .where((e) => e.type == RealtimeEventType.presenceUpdate)
      .map((e) {
        appLogger.i('🟢 Presence update: ${e.data}');
        return e.data;
      });

  // -----------------------------
  // Emit Helpers (Chat-specific)
  // -----------------------------
  void sendTyping({required String conversationId, required bool isTyping}) {
    appLogger.i('⌨️ Sending typing: $isTyping');

    realtime.emit('typing', {
      'conversation_id': conversationId,
      'is_typing': isTyping ? 1 : 0,
    });
  }

  void sendMessageAck(Map<String, dynamic> payload) {
    appLogger.i('✅ Sending message ACK');

    realtime.emit('message_ack', payload);
  }
}
