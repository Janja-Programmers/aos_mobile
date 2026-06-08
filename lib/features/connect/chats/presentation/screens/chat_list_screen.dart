import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/conversation_tile.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/connect_state_view.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/delete_conversation_sheet.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final String? searchQuery;
  final bool hideFilters;

  const ChatListScreen({super.key, this.searchQuery, this.hideFilters = false});

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

  Future<void> _showDeleteConversationSheet(
    ChatConversation conversation,
  ) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DeleteConversationSheet(displayName: conversation.displayName);
      },
    );

    if (shouldDelete != true) return;

    final deleted = await ref
        .read(conversationsControllerProvider.notifier)
        .deleteConversation(conversation.id);

    if (!mounted) return;

    if (deleted) {
      ShowSnack(context, 'Chat deleted from your conversation list.').success();
    } else {
      ShowSnack(context, 'Failed to delete chat. Please try again.').error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsControllerProvider);

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: widget.hideFilters ? const SizedBox.shrink() : _buildFilters(),
        ),

        Expanded(
          child: state.when(
            loading: () => const ConnectStateView.loading(
              title: 'Loading conversations',
              message: 'Please wait while we fetch your chats.',
            ),

            error: (e, _) => ConnectStateView.error(
              title: 'Could not load chats',
              message: 'Check your internet connection and try again.',
              onAction: () {
                ref.read(conversationsControllerProvider.notifier).refresh();
              },
            ),

            data: (conversations) {
              final query = _query.trim().toLowerCase();

              final filtered = conversations.where((conv) {
                final matchesSearch =
                    query.isEmpty ||
                    conv.displayName.toLowerCase().contains(query) ||
                    (conv.lastMessage ?? '').toLowerCase().contains(query);

                final matchesFilter = _applyFilter(conv);

                return matchesSearch && matchesFilter;
              }).toList();

              if (filtered.isEmpty) {
                final hasSearch = query.isNotEmpty;

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: ConnectStateView.empty(
                        icon: hasSearch
                            ? Icons.search_off_rounded
                            : Icons.chat_bubble_outline_rounded,
                        title: hasSearch
                            ? 'No chats found'
                            : 'No conversations yet',
                        message: hasSearch
                            ? 'Try searching with another name or message.'
                            : 'Your conversations will appear here once you start chatting.',
                      ),
                    ),
                  ],
                );
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

                  final subtitle = isTyping ? 'Typing...' : conv.lastMessage;

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
                        otherUserAvatar: conv.avatar,
                      );
                    },
                    onLongPress: () {
                      _showDeleteConversationSheet(conv);
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

  // 🎯 FILTER UI WITH UNREAD BADGES
  Widget _buildFilters() {
    final unreadCount = ref.watch(chatUnreadCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip("All Chats", "all", badgeCount: unreadCount),
            _chip("Read", "read"),
            _chip("Unread", "unread", badgeCount: unreadCount),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, {int badgeCount = 0}) {
    final colors = context.appColors;
    final isSelected = selectedFilter == value;
    final showBadge = badgeCount > 0;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withOpacity(0.1)
                : colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colors.primary.withOpacity(0.35)
                  : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? colors.primary : colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (showBadge) ...[
                const SizedBox(width: 6),
                _chipBadge(count: badgeCount, isSelected: isSelected),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipBadge({required int count, required bool isSelected}) {
    final colors = context.appColors;

    final text = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: context.p.copyWith(
          color: colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
