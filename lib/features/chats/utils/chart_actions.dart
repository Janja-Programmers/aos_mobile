import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/chats/data/chat_api.dart';

class ChatActions {
  const ChatActions._();

  static Future<void> startChat({
    required BuildContext context,
    required WidgetRef ref,
    required String user,
    required String displayName,
    String? initialMessage,
  }) async {
    final api = ref.read(chatApiProvider);

    final res = await api.openConversation(user);

    if (res.isLeft) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.leftOrNull!.message)));
      }
      return;
    }

    final conversationId = res.rightOrNull!;

    if (!context.mounted) return;

    ChatNavigation.toMessage(
      context: context,
      conversationId: conversationId,
      user: user,
      displayName: displayName,
      initialMessage: initialMessage,
    );
  }
}
