import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/chats/controllers/chat_conversations_controller.dart';
import 'package:africaonlinestores/features/chats/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/chats/controllers/chat_typing_controller.dart';
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

        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () =>
              ref.read(chatConversationsControllerProvider.notifier).refresh(),
        ),

        data: (conversations) {
          if (conversations.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(chatConversationsControllerProvider.notifier)
                .refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];

                // 🔥 Watch ONLY what this tile needs
                final presenceMap = ref.watch(chatPresenceControllerProvider);
                final typingMap = ref.watch(chatTypingControllerProvider);

                final presence = presenceMap[conv.user];
                final isTyping = typingMap[conv.id] == true;

                // 🔥 Override message if typing
                final subtitle = isTyping ? "Typing..." : conv.lastMessage;

                final isOnline = ref
                    .read(chatPresenceControllerProvider.notifier)
                    .isUserOnline(conv.user);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 4,
                  ),
                  child: ConversationTile(
                    conversation: conv.copyWith(lastMessage: subtitle),
                    isOnline: isOnline,
                    isTyping: isTyping,
                    lastSeen: presence?.lastSeen,
                    onTap: () {
                      ChatNavigation.toMessage(
                        context: context,
                        conversationId: conv.id,
                        user: conv.user,
                        displayName: conv.displayName,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------
// Empty State
// -----------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("No conversations yet", style: TextStyle(color: Colors.grey)),
    );
  }
}

// -----------------------------
// Error State
// -----------------------------
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}
