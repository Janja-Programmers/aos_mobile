import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/chats/data/chat_api.dart';

class ChatActions {
  const ChatActions._();

  static bool _isOpening = false;

  static Future<void> startChat({
    required BuildContext context,
    required WidgetRef ref,
    required String user,
    required String displayName,
    String? initialMessage,
  }) async {
    // 🚫 Prevent duplicate calls
    if (_isOpening) return;
    _isOpening = true;

    try {
      final api = ref.read(chatApiProvider);

      final res = await api.openConversation(user);

      if (!context.mounted) return;

      if (res.isLeft) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.leftOrNull?.message ?? 'Failed to start chat'),
          ),
        );
        return;
      }

      appLogger.w(
        '🔥 openConversation response: ${res.rightOrNull.toString()}',
      );

      final conversationId = res.rightOrNull;

      if (conversationId == null || conversationId.isEmpty) return;

      ChatNavigation.toMessage(
        context: context,
        conversationId: conversationId,
        user: user,
        displayName: displayName,
        initialMessage: initialMessage,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      _isOpening = false;
    }
  }
}
