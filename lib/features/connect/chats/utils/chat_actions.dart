import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/chats/data/chat_api.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final chatConversationOpenControllerProvider =
    StateNotifierProvider<ChatConversationOpenController, bool>((ref) {
      return ChatConversationOpenController();
    });

class ChatConversationOpenController extends StateNotifier<bool> {
  ChatConversationOpenController() : super(false);

  bool tryBegin() {
    if (state) return false;
    state = true;
    return true;
  }

  void finish() {
    if (!state) return;
    state = false;
  }
}

class ChatActions {
  const ChatActions._();

  static Future<void> startChat({
    required BuildContext context,
    required WidgetRef ref,
    required String user,
    required String displayName,
    String? avatar,
    String? initialMessage,
    String? adId,
    String? adTitle,
    String? adPrice,
    String? adImage,
    String? adImageFileId,
  }) async {
    final guard = ref.read(chatConversationOpenControllerProvider.notifier);
    if (!guard.tryBegin()) return;

    try {
      final api = ref.read(chatApiProvider);

      final res = await api.openConversation(user);

      if (!context.mounted) return;

      if (res.isLeft) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_failed_to_start_chat,
        ).error();
        return;
      }

      final conversationId = res.rightOrNull;

      appLogger.i('Opened conversation: $conversationId');

      if (conversationId == null || conversationId.trim().isEmpty) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_invalid_conversation_response,
        ).error();
        return;
      }

      ChatNavigation.toMessage(
        context: context,
        conversationId: conversationId,
        user: user,
        displayName: displayName,
        otherUserAvatar: avatar,
        initialMessage: initialMessage,
        adId: adId,
        adTitle: adTitle,
        adPrice: adPrice,
        adImage: adImage,
        adImageFileId: adImageFileId,
      );
    } catch (error, stackTrace) {
      if (context.mounted) {
        ShowSnack(
          context,
          AppLocalizations.of(context).chat_failed_to_start_chat,
        ).error();
      }

      appLogger.e(
        'Failed to start chat.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      guard.finish();
    }
  }
}
