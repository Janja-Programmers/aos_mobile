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
    String? adId,
    String? adTitle,
    String? adPrice,
    String? adImage,
    String? adImageFileId,
  }) async {
    if (_isOpening) return;
    _isOpening = true;

    try {
      final api = ref.read(chatApiProvider);

      final res = await api.openConversation(user);

      if (!context.mounted) return;

      if (res.isLeft) {
        ShowSnack(
          context,
          res.leftOrNull?.message ?? 'Failed to start chat. Please try again.',
        ).error();
        return;
      }

      final conversationId = res.rightOrNull;

      appLogger.i('Opened conversation: $conversationId');

      if (conversationId == null || conversationId.trim().isEmpty) {
        ShowSnack(context, 'Invalid conversation response').error();
        return;
      }

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
        adImageFileId: adImageFileId,
      );
    } catch (e) {
      if (context.mounted) {
        ShowSnack(context, 'Failed to start chat. Please try again.').error();
      }

      appLogger.e('Failed to start chat: $e');
    } finally {
      _isOpening = false;
    }
  }
}
