import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/chats/data/chat_api.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ChatActions {
  const ChatActions._();

  static bool _isOpening = false;

  static Future<void> startChat({
    required BuildContext context,
    required WidgetRef ref,
    required String user,
    required String displayName,
    String? initialMessage,
    final String? adId,
    final String? adTitle,
    final String? adPrice,
    final String? adImage,
  }) async {
    // 🚫 Prevent duplicate calls
    if (_isOpening) return;
    _isOpening = true;

    try {
      final api = ref.read(chatApiProvider);

      final res = await api.openConversation(user);

      if (!context.mounted) return;

      if (res.isLeft) {
        ShowSnack(
          context,
          (res.leftOrNull?.message ?? 'Failed to start chat'),
        ).success();
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
        adId: adId,
        adTitle: adTitle,
        adPrice: adPrice,
        adImage: adImage,
      );
    } catch (e) {
      if (context.mounted) {
        ShowSnack(context, ('Error: $e')).error;
      }
    } finally {
      _isOpening = false;
    }
  }
}
