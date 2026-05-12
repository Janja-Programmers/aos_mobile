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
    final cleanAttachments = attachments ?? [];

    final payload = {
      'conversation_id': conversationId,
      'content': content ?? '',
      'attachments': cleanAttachments,
    };

    try {
      final res = await _client.post(
        ApiEndpoints.sendMessageEndpoint,
        data: payload,
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) return Either.left(result.leftOrNull!);

      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(Failure(_friendlySendMessageError(e)));
    } catch (e) {
      return Either.left(
        const Failure('Failed to send message. Please try again.'),
      );
    }
  }

  // -----------------------------
  // Status
  // -----------------------------
  Future<Either<Failure, void>> markDelivered(String conversationId) async {
    final res = await _client.post(
      ApiEndpoints.markDeliveredEndpoint,
      data: {'conversation_id': conversationId},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    return Either.right(null);
  }

  Future<Either<Failure, void>> markRead(String conversationId) async {
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
    final res = await _client.post(
      ApiEndpoints.typingEndpoint,
      data: {'conversation_id': conversationId, 'is_typing': isTyping ? 1 : 0},
    );

    final result = unwrapFrappe(res);
    if (result.isLeft) return Either.left(result.leftOrNull!);

    return Either.right(null);
  }
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
