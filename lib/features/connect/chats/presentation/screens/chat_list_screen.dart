import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/connect/chats/controllers/chat_conversations_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/conversation_tile.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final String? searchQuery;

  const ChatListScreen({super.key, this.searchQuery});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String selectedFilter = "all";
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.searchQuery ?? '';
  }

  @override
  void didUpdateWidget(covariant ChatListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 react to search changes
    if (oldWidget.searchQuery != widget.searchQuery) {
      setState(() {
        _query = widget.searchQuery ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatConversationsControllerProvider);

    return Column(
      children: [
        _buildFilters(),

        Expanded(
          child: state.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (e, _) => _ErrorState(
              message: e.toString(),
              onRetry: () => ref
                  .read(chatConversationsControllerProvider.notifier)
                  .refresh(),
            ),

            data: (conversations) {
              final query = _query.trim().toLowerCase();

              final filtered = conversations.where((conv) {
                final matchesSearch =
                    query.isEmpty ||
                    conv.displayName.toLowerCase().contains(query) ||
                    (conv.lastMessage ?? "").toLowerCase().contains(query);

                final matchesFilter = _applyFilter(conv);

                return matchesSearch && matchesFilter;
              }).toList();

              if (filtered.isEmpty) {
                return const _EmptyState();
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final conv = filtered[index];

                  final presence = ref.watch(
                    chatPresenceControllerProvider.select(
                      (map) => map[conv.user],
                    ),
                  );

                  final isTyping = ref.watch(
                    chatTypingControllerProvider.select(
                      (map) => map[conv.id] == true,
                    ),
                  );

                  final subtitle = isTyping ? "Typing..." : conv.lastMessage;

                  final isOnline = ref
                      .read(chatPresenceControllerProvider.notifier)
                      .isUserOnline(conv.user);

                  return ConversationTile(
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
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 🔥 FILTER LOGIC
  bool _applyFilter(ChatConversation conv) {
    switch (selectedFilter) {
      case "read":
        return conv.unreadCount == 0;

      case "unread":
        return conv.unreadCount > 0;

      default:
        return true;
    }
  }

  // 🎯 FILTER UI (FIXED CENTERING)
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip("All Chat", "all"),
          _chip("Read", "read"),
          _chip("Unread", "unread"),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final colors = context.appColors;
    final isSelected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withOpacity(0.1)
                : colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.primary : colors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
