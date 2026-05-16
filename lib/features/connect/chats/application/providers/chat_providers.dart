import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_conversations_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/features/connect/chats/data/services/chat_realtime_service.dart';

//********************
// REALTIME service provider (singleton)
//********************
final chatRealtimeServiceProvider = Provider<ChatRealtimeService>((ref) {
  return ChatRealtimeService(ref.read(realtimeServiceProvider));
});

//********************
// CHATCONVERSATION Controller
//********************
final chatConversationsControllerProvider =
    StateNotifierProvider<
      ChatConversationsController,
      AsyncValue<List<ChatConversation>>
    >((ref) => ChatConversationsController(ref));

//********************
// CHATMESSAGES Controller
//********************
final chatMessagesControllerProvider =
    StateNotifierProvider.family<
      ChatMessagesController,
      AsyncValue<List<ChatMessage>>,
      String
    >((ref, conversationId) {
      return ChatMessagesController(ref, conversationId);
    });

//********************
// CHATUNREADCOUNT Provider
//********************
final chatUnreadCountProvider = Provider<int>((ref) {
  final conversationsState = ref.watch(chatConversationsControllerProvider);

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
