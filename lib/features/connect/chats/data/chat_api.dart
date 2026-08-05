import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_status_update.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    try {
      final res = await _client.post(
        ApiEndpoints.openConversationEndpoint,
        data: {'user': user},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final payload = asJsonMap(result.rightOrNull);
      final data = asJsonMap(payload['data']);

      final conversationId = data['id'];

      if (conversationId == null) {
        return Either.left(const Failure('Invalid conversation response'));
      }

      return Either.right(conversationId.toString());
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to start chat. Please try again.',
        ),
      );
    }
  }

  Future<Either<Failure, List<ChatConversation>>> listConversations({
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listConversationsEndpoint,
        queryParameters: <String, dynamic>{
          'limit': limit.clamp(1, 50),
          'offset': offset < 0 ? 0 : offset,
        },
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) return Either.left(result.leftOrNull!);

      final rawData = result.rightOrNull!;

      final conversations = asJsonMapList(
        rawData['data'],
      ).map(ChatConversation.fromJson).toList(growable: false);

      return Either.right(conversations);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to load conversations',
        ),
      );
    }
  }

  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
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
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to delete conversation',
        ),
      );
    }
  }

  // -----------------------------
  // Messages
  // -----------------------------
  Future<Either<Failure, List<ChatMessage>>> listMessages({
    required String conversationId,
    String? before,
  }) async {
    try {
      final queryParams = <String, dynamic>{'conversation_id': conversationId};
      if (before != null) queryParams['before'] = before;

      final res = await _client.get(
        ApiEndpoints.listMessagesEndpoint,
        queryParameters: queryParams,
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = _extractDataPayload(result.rightOrNull);
      final messages = asJsonMapList(
        data,
      ).map(ChatMessage.fromJson).toList(growable: false);

      if (messages.isEmpty && data is! List) {
        return Either.left(
          const Failure(
            'Invalid messages response from chat API',
            type: FailureType.parse,
          ),
        );
      }

      return Either.right(messages);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to load messages',
        ),
      );
    }
  }

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    String? content,
    String? ad,
    String? replyToMessage,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final cleanAttachments = attachments ?? [];

    final cleanAd = ad?.trim();

    final payload = {
      'conversation_id': conversationId,
      'content': content ?? '',
      'attachments': cleanAttachments,
      if (cleanAd != null && cleanAd.isNotEmpty) 'ad': cleanAd,
      if (replyToMessage != null && replyToMessage.trim().isNotEmpty)
        'reply_to_message': replyToMessage.trim(),
    };

    try {
      final res = await _client.post(
        ApiEndpoints.sendMessageEndpoint,
        data: payload,
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      final raw = result.rightOrNull;
      final messageData = _extractDataPayload(raw);

      if (messageData is! Map) {
        return Either.left(
          const Failure('Invalid message response from chat API'),
        );
      }

      final message = ChatMessage.fromJson(asJsonMap(messageData));

      if (message.id.trim().isEmpty) {
        return Either.left(const Failure('Invalid message id from chat API'));
      }

      return Either.right(message);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to send message. Please try again.',
        ),
      );
    }
  }

  Future<Either<Failure, ChatMessage>> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.editMessageEndpoint,
        data: {'message_id': messageId, 'content': content},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final messageData = _extractDataPayload(result.rightOrNull);
      if (messageData is! Map) {
        return Either.left(const Failure('Invalid edit message response'));
      }

      return Either.right(ChatMessage.fromJson(asJsonMap(messageData)));
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to edit message',
        ),
      );
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> deleteMessages({
    required List<String> messageIds,
    required String deleteScope,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteMessagesEndpoint,
        data: {'message_ids': messageIds, 'delete_scope': deleteScope},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = _extractDataPayload(result.rightOrNull);
      return Either.right(data is Map ? asJsonMap(data) : <String, dynamic>{});
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to delete messages',
        ),
      );
    }
  }

  Future<Either<Failure, void>> clearChat(String conversationId) async {
    try {
      final res = await _client.post(
        ApiEndpoints.clearChatEndpoint,
        data: {'conversation_id': conversationId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to clear chat',
        ),
      );
    }
  }

  Future<Either<Failure, bool>> toggleMessageStar(String messageId) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleMessageStarEndpoint,
        data: {'message_id': messageId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = asJsonMap(_extractDataPayload(result.rightOrNull));
      final isStarred = asBool(data['is_starred']);

      return Either.right(isStarred);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to update star',
        ),
      );
    }
  }

  Future<Either<Failure, List<ChatMessage>>> listStarredMessages({
    String? conversationId,
    String? before,
    int limit = 30,
  }) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (conversationId != null && conversationId.trim().isNotEmpty) {
        params['conversation_id'] = conversationId.trim();
      }
      if (before != null && before.trim().isNotEmpty) {
        params['before'] = before.trim();
      }

      final res = await _client.get(
        ApiEndpoints.listStarredMessagesEndpoint,
        queryParameters: params,
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = _extractDataPayload(result.rightOrNull);
      final messages = asJsonMapList(
        data,
      ).map(ChatMessage.fromJson).toList(growable: false);

      return Either.right(messages);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to load starred messages',
        ),
      );
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> toggleMessageReaction({
    required String messageId,
    required String? emoji,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.toggleMessageReactionEndpoint,
        data: {'message_id': messageId, 'emoji': emoji},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = _extractDataPayload(result.rightOrNull);
      return Either.right(data is Map ? asJsonMap(data) : <String, dynamic>{});
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to update reaction',
        ),
      );
    }
  }

  Future<Either<Failure, List<ChatMessage>>> forwardMessage({
    required String messageId,
    required List<String> targetConversationIds,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.forwardMessageEndpoint,
        data: {
          'message_id': messageId,
          'target_conversation_ids': targetConversationIds,
        },
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = asJsonMap(_extractDataPayload(result.rightOrNull));
      final rows = asJsonMapList(data['messages']);

      final messages = rows
          .map((row) => asJsonMap(row['message']))
          .where((message) => message.isNotEmpty)
          .map(ChatMessage.fromJson)
          .toList(growable: false);

      return Either.right(messages);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to forward message',
        ),
      );
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> translateMessage({
    required String messageId,
    required String targetLanguage,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.translateMessageEndpoint,
        data: {'message_id': messageId, 'target_language': targetLanguage},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = _extractDataPayload(result.rightOrNull);
      return Either.right(data is Map ? asJsonMap(data) : <String, dynamic>{});
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Message translation is not available yet',
        ),
      );
    }
  }

  // -----------------------------
  // Status
  // -----------------------------
  Future<Either<Failure, ChatMessageStatusUpdate>> markDelivered(
    String conversationId,
  ) async {
    try {
      final res = await _client.post(
        ApiEndpoints.markDeliveredEndpoint,
        data: {'conversation_id': conversationId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = _extractDataPayload(result.rightOrNull);
      return Either.right(
        data is Map
            ? ChatMessageStatusUpdate.fromJson(asJsonMap(data))
            : const ChatMessageStatusUpdate.empty(),
      );
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to mark messages as delivered',
        ),
      );
    }
  }

  Future<Either<Failure, ChatMessageStatusUpdate>> markRead(
    String conversationId,
  ) async {
    try {
      final res = await _client.post(
        ApiEndpoints.markReadEndpoint,
        data: {'conversation_id': conversationId},
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final data = _extractDataPayload(result.rightOrNull);
      return Either.right(
        data is Map
            ? ChatMessageStatusUpdate.fromJson(asJsonMap(data))
            : const ChatMessageStatusUpdate.empty(),
      );
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to mark messages as read',
        ),
      );
    }
  }

  // -----------------------------
  // Typing
  // -----------------------------
  Future<Either<Failure, void>> sendTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.typingEndpoint,
        data: {
          'conversation_id': conversationId,
          'is_typing': isTyping ? 1 : 0,
        },
      );

      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } catch (error) {
      return Either.left(
        _chatFailureFromException(
          error,
          fallbackMessage: 'Failed to update typing status',
        ),
      );
    }
  }
}

Object? _extractDataPayload(Map<String, dynamic>? raw) {
  if (raw == null) return null;

  final data = raw['data'];
  if (data != null) return data;

  final nestedMessage = raw['message'];
  if (nestedMessage is Map) {
    final nestedData = nestedMessage['data'];
    if (nestedData != null) return nestedData;
  }

  return raw;
}

Failure _chatFailureFromException(
  Object error, {
  required String fallbackMessage,
}) {
  if (error is! DioException) {
    return Failure(fallbackMessage, type: FailureType.unknown);
  }

  final response = error.response;
  final statusCode = response?.statusCode;
  final raw = response?.data;
  if (raw is Map<Object?, Object?>) {
    final root = asJsonMap(raw);
    final nestedMessage = root['message'];
    final payload = nestedMessage is Map<Object?, Object?>
        ? asJsonMap(nestedMessage)
        : root;

    return Failure.fromServerPayload(
      payload,
      statusCode: statusCode,
      fallbackMessage: fallbackMessage,
    );
  }

  return Failure(
    fallbackMessage,
    statusCode: statusCode,
    type: _failureTypeForDio(error),
  );
}

FailureType _failureTypeForDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return FailureType.timeout;
    case DioExceptionType.connectionError:
      return FailureType.network;
    case DioExceptionType.badResponse:
      return failureTypeForAuthError(
        null,
        statusCode: error.response?.statusCode,
      );
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return error.response == null ? FailureType.network : FailureType.unknown;
  }
}
