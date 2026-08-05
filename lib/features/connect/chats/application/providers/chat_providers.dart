import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/data/services/chat_realtime_service.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//********************
// REALTIME service provider (singleton)
//********************
final chatRealtimeServiceProvider = Provider<ChatRealtimeService>((ref) {
  return ChatRealtimeService(ref.read(realtimeServiceProvider));
});

//********************
// CHATMESSAGES Controller
//********************
final chatMessagesControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesController, ChatMessagesState, String>((
      ref,
      conversationId,
    ) {
      return ChatMessagesController(ref, conversationId);
    });

//********************
// CHATUNREADCOUNT Provider
//********************
final chatUnreadCountProvider = Provider<int>((ref) {
  final conversationsState = ref.watch(conversationsControllerProvider);

  return conversationsState.maybeWhen(
    data: (conversations) {
      return conversations.fold<int>(
        0,
        (total, conversation) => total + conversation.unreadCount,
      );
    },
    orElse: () => 0,
  );
});
