import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/connect/chats/data/chat_api.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_status_update.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    String? content,
    String? ad,
    String? replyToMessage,
    List<Map<String, dynamic>>? attachments,
  }) {
    return api.sendMessage(
      conversationId: conversationId,
      content: content,
      ad: ad,
      replyToMessage: replyToMessage,
      attachments: attachments,
    );
  }

  Future<Either<Failure, ChatMessage>> editMessage({
    required String messageId,
    required String content,
  }) {
    return api.editMessage(messageId: messageId, content: content);
  }

  Future<Either<Failure, Map<String, dynamic>>> deleteMessages({
    required List<String> messageIds,
    required String deleteScope,
  }) {
    return api.deleteMessages(messageIds: messageIds, deleteScope: deleteScope);
  }

  Future<Either<Failure, void>> clearChat(String conversationId) {
    return api.clearChat(conversationId);
  }

  Future<Either<Failure, bool>> toggleMessageStar(String messageId) {
    return api.toggleMessageStar(messageId);
  }

  Future<Either<Failure, List<ChatMessage>>> listStarredMessages({
    String? conversationId,
    String? before,
    int limit = 30,
  }) {
    return api.listStarredMessages(
      conversationId: conversationId,
      before: before,
      limit: limit,
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> toggleMessageReaction({
    required String messageId,
    required String? emoji,
  }) {
    return api.toggleMessageReaction(messageId: messageId, emoji: emoji);
  }

  Future<Either<Failure, List<ChatMessage>>> forwardMessage({
    required String messageId,
    required List<String> targetConversationIds,
  }) {
    return api.forwardMessage(
      messageId: messageId,
      targetConversationIds: targetConversationIds,
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> translateMessage({
    required String messageId,
    required String targetLanguage,
  }) {
    return api.translateMessage(
      messageId: messageId,
      targetLanguage: targetLanguage,
    );
  }

  // -----------------------------
  // Status
  // -----------------------------
  Future<Either<Failure, ChatMessageStatusUpdate>> markDelivered(
    String conversationId,
  ) {
    return api.markDelivered(conversationId);
  }

  Future<Either<Failure, ChatMessageStatusUpdate>> markRead(
    String conversationId,
  ) {
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
