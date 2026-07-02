import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/connect_state_view.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/conversation_tile.dart';
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
  String selectedFilter = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.searchQuery ?? '';
  }

  @override
  void didUpdateWidget(covariant ChatListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

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

  Future<void> _refresh() {
    return ref.read(conversationsControllerProvider.notifier).refresh();
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
            error: (e, _) => RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ConnectStateView.error(
                      title: 'Could not load chats',
                      message: 'Check your internet connection and try again.',
                      onAction: _refresh,
                    ),
                  ),
                ],
              ),
            ),
            data: (conversations) {
              final query = _query.trim().toLowerCase();

              final filtered = conversations.where((conv) {
                final matchesSearch =
                    query.isEmpty ||
                    conv.displayName.toLowerCase().contains(query) ||
                    (conv.lastMessage ?? '').toLowerCase().contains(query);

                return matchesSearch && _applyFilter(conv);
              }).toList();

              if (filtered.isEmpty) {
                final hasSearch = query.isNotEmpty;

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ConnectStateView.empty(
                          icon: hasSearch
                              ? Icons.search_off_rounded
                              : Icons.chat_bubble_outline_rounded,
                          title: hasSearch
                              ? 'No chats found'
                              : _emptyTitleForFilter(),
                          message: hasSearch
                              ? 'Try searching with another name or message.'
                              : _emptyMessageForFilter(),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
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
                        (map) => map[conv.id] ?? false,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _applyFilter(ChatConversation conv) {
    switch (selectedFilter) {
      case 'read':
        return conv.unreadCount == 0;
      case 'unread':
        return conv.unreadCount > 0;
      default:
        return true;
    }
  }

  Widget _buildFilters() {
    final colors = context.appColors;
    final unreadCount = ref.watch(chatUnreadCountProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _filterTitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.h4.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 23,
              ),
            ),
          ),
          PopupMenuButton<String>(
            initialValue: selectedFilter,
            color: colors.elevated,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.border),
            ),
            offset: const Offset(0, 42),
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder: (context) => [
              _filterMenuItem('All', 'all'),
              _filterMenuItem('Read', 'read'),
              _filterMenuItem(
                unreadCount > 0 ? 'Unread ($unreadCount)' : 'Unread',
                'unread',
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list_rounded, color: colors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: context.p.copyWith(
                    color: colors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _filterMenuItem(String label, String value) {
    final colors = context.appColors;
    final selected = selectedFilter == value;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? colors.primary : colors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(label, style: context.p),
        ],
      ),
    );
  }

  String _filterTitle() {
    switch (selectedFilter) {
      case 'read':
        return 'Read Chats';
      case 'unread':
        return 'Unread Chats';
      default:
        return 'All Chats';
    }
  }

  String _emptyTitleForFilter() {
    switch (selectedFilter) {
      case 'read':
        return 'No read chats';
      case 'unread':
        return 'No unread chats';
      default:
        return 'No conversations yet';
    }
  }

  String _emptyMessageForFilter() {
    switch (selectedFilter) {
      case 'read':
        return 'Chats you have already read will appear here.';
      case 'unread':
        return 'Unread chats will appear here as new messages arrive.';
      default:
        return 'Your conversations will appear here once you start chatting.';
    }
  }
}
