import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_presence_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_typing_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/connect_state_view.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/conversation_tile.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/delete_conversation_sheet.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final String? searchQuery;
  final bool hideFilters;

  const ChatListScreen({super.key, this.searchQuery, this.hideFilters = false});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final ScrollController _scrollController = ScrollController();
  String selectedFilter = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.searchQuery ?? '';
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 260) return;
    ref.read(conversationsControllerProvider.notifier).loadMore();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_deleted_from_list,
      ).success();
    } else {
      ShowSnack(
        context,
        AppLocalizations.of(context).chat_delete_chat_failed,
      ).error();
    }
  }

  Future<void> _refresh() {
    return ref.read(conversationsControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(conversationsControllerProvider);
    final currentUserCanonicalId = ref.watch(currentCanonicalAccountIdProvider);

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
            loading: () => ConnectStateView.loading(
              title: l10n.chat_loading_conversations,
              message: l10n.chat_loading_conversations_hint,
            ),
            error: (e, _) => RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ConnectStateView.error(
                      title: l10n.chat_could_not_load_chats,
                      message: l10n.chat_check_connection_try_again,
                      onAction: _refresh,
                    ),
                  ),
                ],
              ),
            ),
            data: (conversations) {
              final query = _query.trim().toLowerCase();
              final conversationsNotifier = ref.read(
                conversationsControllerProvider.notifier,
              );
              final isLoadingMore = conversationsNotifier.isLoadingMore;

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
                              ? l10n.chat_no_chats_found
                              : _emptyTitleForFilter(l10n),
                          message: hasSearch
                              ? l10n.chat_no_chats_search_hint
                              : _emptyMessageForFilter(l10n),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: filtered.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= filtered.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
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

                    final subtitle = isTyping
                        ? l10n.chat_typing
                        : conv.lastMessage;

                    final isOnline = ref
                        .read(chatPresenceControllerProvider.notifier)
                        .isUserOnline(conv.user);

                    return ConversationTile(
                      conversation: conv.copyWith(lastMessage: subtitle),
                      currentUserCanonicalId: currentUserCanonicalId,
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
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: Row(
        children: [
          _ChatFilterButton(
            label: l10n.chat_all_chats,
            selected: selectedFilter == 'all',
            onTap: () => setState(() => selectedFilter = 'all'),
          ),
          const SizedBox(width: 6),
          _ChatFilterButton(
            label: l10n.chat_unread,
            selected: selectedFilter == 'unread',
            onTap: () => setState(() => selectedFilter = 'unread'),
          ),
          const SizedBox(width: 6),
          _ChatFilterButton(
            label: l10n.chat_read,
            selected: selectedFilter == 'read',
            onTap: () => setState(() => selectedFilter = 'read'),
          ),
        ],
      ),
    );
  }

  String _emptyTitleForFilter(AppLocalizations l10n) {
    switch (selectedFilter) {
      case 'read':
        return l10n.chat_no_read_chats;
      case 'unread':
        return l10n.chat_no_unread_chats;
      default:
        return l10n.chat_no_conversations_yet;
    }
  }

  String _emptyMessageForFilter(AppLocalizations l10n) {
    switch (selectedFilter) {
      case 'read':
        return l10n.chat_no_read_chats_hint;
      case 'unread':
        return l10n.chat_no_unread_chats_hint;
      default:
        return l10n.chat_no_conversations_hint;
    }
  }
}

class _ChatFilterButton extends StatelessWidget {
  const _ChatFilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.p.copyWith(
                fontSize: 13,
                color: selected ? colors.primary : colors.textMuted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
