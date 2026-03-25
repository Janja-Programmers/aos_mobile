import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/chats/controllers/chat_conversations_controller.dart';
import 'package:africaonlinestores/features/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/chats/presentation/widgets/conversation_tile.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatConversationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text("No conversations yet"));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];

              return ConversationTile(
                conversation: conv,
                onTap: () => ChatNavigation.toMessage(
                  context: context,
                  conversationId: conv.id,
                  user: conv.user,
                  displayName: conv.displayName,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
