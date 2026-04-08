import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/chats/data/chat_api.dart';
import 'package:africaonlinestores/features/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/chats/domain/chat_message.dart';

/// Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final api = ref.read(chatApiProvider);
  return ChatRepository(api);
});

class ChatRepository {
  final ChatApi api;

  ChatRepository(this.api);

  // -----------------------------
  // Conversation
  // -----------------------------
  Future<Either<Failure, String>> openConversation(String user) {
    return api.openConversation(user);
  }

  Future<Either<Failure, List<ChatConversation>>> getConversations() {
    return api.listConversations();
  }

  Future<Either<Failure, void>> deleteConversation(String conversationId) {
    return api.deleteConversation(conversationId);
  }

  // -----------------------------
  // Messages
  // -----------------------------
  Future<Either<Failure, List<ChatMessage>>> getMessages({
    required String conversationId,
    String? before,
  }) {
    return api.listMessages(conversationId: conversationId, before: before);
  }

  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? attachments,
  }) {
    return api.sendMessage(
      conversationId: conversationId,
      content: content,
      attachments: attachments,
    );
  }

  // -----------------------------
  // Status
  // -----------------------------
  Future<Either<Failure, void>> markDelivered(String conversationId) {
    return api.markDelivered(conversationId);
  }

  Future<Either<Failure, void>> markRead(String conversationId) {
    return api.markRead(conversationId);
  }

  // -----------------------------
  // Typing
  // -----------------------------
  Future<Either<Failure, void>> sendTyping({
    required String conversationId,
    required bool isTyping,
  }) {
    return api.sendTyping(conversationId: conversationId, isTyping: isTyping);
  }
}
