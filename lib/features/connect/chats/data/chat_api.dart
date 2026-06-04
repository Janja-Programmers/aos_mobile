import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_status_update.dart';

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

      final payload = result.rightOrNull!;

      final conversationId = payload['data']?['id'];

      if (conversationId == null) {
        return Either.left(const Failure('Invalid conversation response'));
      }

      return Either.right(conversationId.toString());
    } on DioException catch (e) {
      return Either.left(Failure(_friendlyOpenConversationError(e)));
    } catch (_) {
      return Either.left(
        const Failure('Failed to start chat. Please try again.'),
      );
    }
  }

  Future<Either<Failure, List<ChatConversation>>> listConversations() async {
    try {
      final res = await _client.get(ApiEndpoints.listConversationsEndpoint);

      final result = unwrapFrappe(res);

      if (result.isLeft) return Either.left(result.leftOrNull!);

      final rawData = result.rightOrNull!;

      final dataList = rawData['data'] is List ? rawData['data'] as List : [];

      final conversations = dataList
          .whereType<Map<String, dynamic>>()
          .map((e) => ChatConversation.fromJson(e))
          .toList();

      return Either.right(conversations);
    } catch (e) {
      return Either.left(const Failure('Failed to load conversations'));
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
    final queryParams = <String, dynamic>{'conversation_id': conversationId};
    if (before != null) queryParams['before'] = before;

    final res = await _client.get(
      ApiEndpoints.listMessagesEndpoint,
      queryParameters: queryParams,
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final data = _extractDataPayload(result.rightOrNull);
    if (data is! List) {
      return Either.left(const Failure('Empty response from chat API'));
    }

    final messages = data
        .whereType<Map>()
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Either.right(messages);
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

      final message = ChatMessage.fromJson(
        Map<String, dynamic>.from(messageData),
      );

      if (message.id.trim().isEmpty) {
        return Either.left(const Failure('Invalid message id from chat API'));
      }

      return Either.right(message);
    } on DioException catch (e) {
      return Either.left(Failure(_friendlySendMessageError(e)));
    } catch (_) {
      return Either.left(
        const Failure('Failed to send message. Please try again.'),
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

      return Either.right(
        ChatMessage.fromJson(Map<String, dynamic>.from(messageData)),
      );
    } catch (_) {
      return Either.left(const Failure('Failed to edit message'));
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
      return Either.right(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      );
    } catch (_) {
      return Either.left(const Failure('Failed to delete messages'));
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
    } catch (_) {
      return Either.left(const Failure('Failed to clear chat'));
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

      final data = _extractDataPayload(result.rightOrNull);
      final isStarred =
          data is Map &&
          (data['is_starred'] == true || data['is_starred'] == 1);

      return Either.right(isStarred);
    } catch (_) {
      return Either.left(const Failure('Failed to update star'));
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
      final messages = (data is List ? data : const [])
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return Either.right(messages);
    } catch (_) {
      return Either.left(const Failure('Failed to load starred messages'));
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
      return Either.right(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      );
    } catch (_) {
      return Either.left(const Failure('Failed to update reaction'));
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

      final data = _extractDataPayload(result.rightOrNull);
      final rows = data is Map ? data['messages'] : null;

      final messages = (rows is List ? rows : const [])
          .whereType<Map>()
          .map((row) => row['message'])
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return Either.right(messages);
    } catch (_) {
      return Either.left(const Failure('Failed to forward message'));
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
      return Either.right(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      );
    } catch (_) {
      return Either.left(
        const Failure('Message translation is not available yet'),
      );
    }
  }

  // -----------------------------
  // Status
  // -----------------------------
  Future<Either<Failure, ChatMessageStatusUpdate>> markDelivered(
    String conversationId,
  ) async {
    final res = await _client.post(
      ApiEndpoints.markDeliveredEndpoint,
      data: {'conversation_id': conversationId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final data = _extractDataPayload(result.rightOrNull);
    return Either.right(
      data is Map
          ? ChatMessageStatusUpdate.fromJson(Map<String, dynamic>.from(data))
          : const ChatMessageStatusUpdate.empty(),
    );
  }

  Future<Either<Failure, ChatMessageStatusUpdate>> markRead(
    String conversationId,
  ) async {
    final res = await _client.post(
      ApiEndpoints.markReadEndpoint,
      data: {'conversation_id': conversationId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    final data = _extractDataPayload(result.rightOrNull);
    return Either.right(
      data is Map
          ? ChatMessageStatusUpdate.fromJson(Map<String, dynamic>.from(data))
          : const ChatMessageStatusUpdate.empty(),
    );
  }

  // -----------------------------
  // Typing
  // -----------------------------
  Future<Either<Failure, void>> sendTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    final res = await _client.post(
      ApiEndpoints.typingEndpoint,
      data: {'conversation_id': conversationId, 'is_typing': isTyping ? 1 : 0},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    return Either.right(null);
  }
}

dynamic _extractDataPayload(Map<String, dynamic>? raw) {
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

String _friendlyOpenConversationError(DioException e) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;

  final serverMessage = _extractServerMessage(data);

  if (serverMessage != null && serverMessage.trim().isNotEmpty) {
    return serverMessage;
  }

  switch (statusCode) {
    case 400:
      return 'Unable to start this chat.';
    case 401:
      return 'Please log in to start a chat.';
    case 403:
      return 'You are not allowed to start this chat.';
    case 404:
      return 'User not found.';
    case 409:
      return 'This conversation already exists.';
    case 429:
      return 'Too many chat attempts. Please try again shortly.';
    case 500:
    case 502:
    case 503:
      return 'Chat service is temporarily unavailable. Please try again.';
    default:
      return 'Failed to start chat. Please try again.';
  }
}

String _friendlySendMessageError(DioException e) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;

  final serverMessage = _extractServerMessage(data);

  if (serverMessage != null && serverMessage.trim().isNotEmpty) {
    return serverMessage;
  }

  switch (statusCode) {
    case 400:
      return 'Message could not be sent. Please check the message or attachment.';
    case 401:
      return 'Please log in to send messages.';
    case 403:
      return 'You are not allowed to send messages in this conversation.';
    case 404:
      return 'Conversation not found.';
    case 413:
      return 'Attachment is too large.';
    case 429:
      return 'You are sending messages too quickly. Please try again shortly.';
    case 500:
    case 502:
    case 503:
      return 'Chat service is temporarily unavailable. Please try again.';
    default:
      return 'Failed to send message. Please try again.';
  }
}

String? _extractServerMessage(dynamic data) {
  if (data is! Map) return null;

  final directMessage = data['message'];
  if (directMessage is String && directMessage.trim().isNotEmpty) {
    return directMessage;
  }

  final exception = data['exception'];
  if (exception is String && exception.trim().isNotEmpty) {
    return _cleanFrappeException(exception);
  }

  final exc = data['exc'];
  if (exc is String && exc.trim().isNotEmpty) {
    return _cleanFrappeException(exc);
  }

  final serverMessages = data['_server_messages'];
  if (serverMessages is String && serverMessages.trim().isNotEmpty) {
    return _cleanFrappeException(serverMessages);
  }

  return null;
}

String _cleanFrappeException(String raw) {
  var message = raw;

  // Remove common Python/Frappe exception prefixes.
  if (message.contains(':')) {
    message = message.split(':').last;
  }

  return message
      .replaceAll(r'\"', '"')
      .replaceAll('\\n', ' ')
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll('{', '')
      .replaceAll('}', '')
      .replaceAll('"message":', '')
      .replaceAll('"', '')
      .trim();
}
