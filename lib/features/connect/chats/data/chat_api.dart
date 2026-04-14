import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';

/// Provider
final chatApiProvider = Provider<ChatApi>((ref) {
  return ChatApi(ref.read(apiClientProvider));
});

class ChatApi {
  final ApiClient _client;

  ChatApi(this._client);

  // -----------------------------
  // Conversations
  // -----------------------------
  Future<Either<Failure, String>> openConversation(String user) async {
    appLogger.i("openConversation API");
    final res = await _client.post(
      ApiEndpoints.openConversationEndpoint,
      data: {'user': user},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final payload = result.rightOrNull!;

    final conversationId = payload['data']?['id'];

    if (conversationId == null) {
      return Either.left(const Failure('Invalid conversation response'));
    }

    return Either.right(conversationId.toString());
  }

  Future<Either<Failure, List<ChatConversation>>> listConversations() async {
    appLogger.i("listConversations API");

    try {
      final res = await _client.get(ApiEndpoints.listConversationsEndpoint);

      final result = unwrapFrappe(res);
      appLogger.w("Results: ${result.toString()}");

      if (result.isLeft) return Either.left(result.leftOrNull!);

      final rawData = result.rightOrNull!;
      appLogger.w("RawData: ${rawData.toString()}");
      final dataList = rawData['data'] is List ? rawData['data'] as List : [];
      appLogger.w("Datalist: ${dataList.toString()}");

      final conversations = dataList
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatConversation.fromJson(e))
          .toList();

      appLogger.w("Conversations: ${conversations.toString()}");

      return Either.right(conversations);
    } catch (e) {
      return Either.left(const Failure('Failed to load conversations'));
    }
  }

  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    appLogger.i("deleteConversation API: $conversationId");

    try {
      final res = await _client.post(
        ApiEndpoints.deleteConversationEndpoint,
        data: {'conversation_id': conversationId},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      return Either.right(null);
    } catch (e) {
      return Either.left(const Failure('Failed to delete conversation'));
    }
  }

  // -----------------------------
  // Messages
  // -----------------------------
  Future<Either<Failure, List<ChatMessage>>> listMessages({
    required String conversationId,
    String? before,
  }) async {
    appLogger.i("listMessages API");

    final queryParams = <String, dynamic>{'conversation_id': conversationId};
    if (before != null) queryParams['before'] = before;

    final res = await _client.get(
      ApiEndpoints.listMessagesEndpoint,
      queryParameters: queryParams,
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final data = result.rightOrNull;
    if (data == null || data['data'] == null) {
      return Either.left(const Failure('Empty response from chat API'));
    }

    final messagesData = data['data'] as List<dynamic>;
    final messages = messagesData
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();

    return Either.right(messages);
  }

  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    String? content,
    List<Map<String, dynamic>>? attachments,
  }) async {
    appLogger.i("sendMessage API");

    final res = await _client.post(
      ApiEndpoints.sendMessageEndpoint,
      data: {
        'conversation_id': conversationId,
        'content': content ?? '',
        'attachments': attachments ?? [],
      },
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    return Either.right(null);
  }

  // -----------------------------
  // Status
  // -----------------------------
  Future<Either<Failure, void>> markDelivered(String conversationId) async {
    appLogger.i("markDelivered API");

    final res = await _client.post(
      ApiEndpoints.markDeliveredEndpoint,
      data: {'conversation_id': conversationId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    return Either.right(null);
  }

  Future<Either<Failure, void>> markRead(String conversationId) async {
    appLogger.i("markRead API");

    final res = await _client.post(
      ApiEndpoints.markReadEndpoint,
      data: {'conversation_id': conversationId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    return Either.right(null);
  }

  // -----------------------------
  // Typing
  // -----------------------------
  Future<Either<Failure, void>> sendTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    appLogger.i("sendTyping API");

    final res = await _client.post(
      ApiEndpoints.typingEndpoint,
      data: {'conversation_id': conversationId, 'is_typing': isTyping ? 1 : 0},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    return Either.right(null);
  }
}
