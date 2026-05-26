import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/converaation/application/controllers/chat_conversations_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//********************
// CONVERSATION Controller
//********************
final conversationsControllerProvider =
    StateNotifierProvider<
      ConversationsController,
      AsyncValue<List<ChatConversation>>
    >((ref) => ConversationsController(ref));
