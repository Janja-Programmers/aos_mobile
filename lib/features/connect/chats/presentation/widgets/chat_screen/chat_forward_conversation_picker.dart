import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<ChatConversation>?> showChatForwardConversationPicker({
  required BuildContext context,
  required String currentConversationId,
}) {
  return showModalBottomSheet<List<ChatConversation>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return ChatForwardConversationPicker(
        currentConversationId: currentConversationId,
      );
    },
  );
}

class ChatForwardConversationPicker extends ConsumerStatefulWidget {
  final String currentConversationId;

  const ChatForwardConversationPicker({
    super.key,
    required this.currentConversationId,
  });

  @override
  ConsumerState<ChatForwardConversationPicker> createState() =>
      _ChatForwardConversationPickerState();
}

class _ChatForwardConversationPickerState
    extends ConsumerState<ChatForwardConversationPicker> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(conversationsControllerProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .16),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.chat_forward_to_title,
                          style: context.h5.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.chat_close,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() => _query = value.trim().toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: l10n.chat_search_conversations_hint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.chat_clear_search,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: colors.surfaceBright,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: state.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    error: (_, _) => _ForwardPickerEmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: l10n.chat_could_not_load_conversations,
                      message: l10n.chat_check_connection_try_again,
                      actionLabel: l10n.chat_retry,
                      onAction: () {
                        ref
                            .read(conversationsControllerProvider.notifier)
                            .refresh();
                      },
                    ),
                    data: (conversations) {
                      final filtered = conversations.where((conversation) {
                        if (conversation.id == widget.currentConversationId) {
                          return false;
                        }

                        if (_query.isEmpty) return true;

                        final name = conversation.displayName.toLowerCase();
                        final lastMessage =
                            conversation.lastMessage?.toLowerCase() ?? '';
                        return name.contains(_query) ||
                            lastMessage.contains(_query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return _ForwardPickerEmptyState(
                          icon: _query.isEmpty
                              ? Icons.chat_bubble_outline_rounded
                              : Icons.search_off_rounded,
                          title: _query.isEmpty
                              ? l10n.chat_no_other_conversations
                              : l10n.chat_no_conversations_found,
                          message: _query.isEmpty
                              ? l10n.chat_no_other_conversations_hint
                              : l10n.chat_search_conversations_empty_hint,
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 96),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          indent: 74,
                          color: colors.border.withValues(alpha: .65),
                        ),
                        itemBuilder: (context, index) {
                          final conversation = filtered[index];
                          final isSelected = _selectedIds.contains(
                            conversation.id,
                          );

                          return _ForwardConversationTile(
                            conversation: conversation,
                            selected: isSelected,
                            onTap: () => _toggle(conversation.id),
                          );
                        },
                      );
                    },
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _selectedIds.isEmpty
                      ? const SizedBox.shrink()
                      : _ForwardPickerBottomBar(
                          selectedCount: _selectedIds.length,
                          onSend: () => _finish(state),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggle(String conversationId) {
    setState(() {
      if (_selectedIds.contains(conversationId)) {
        _selectedIds.remove(conversationId);
      } else {
        _selectedIds.add(conversationId);
      }
    });
  }

  void _finish(AsyncValue<List<ChatConversation>> state) {
    final conversations = state.maybeWhen(
      data: (value) => value,
      orElse: () => const <ChatConversation>[],
    );

    final selected = conversations
        .where((conversation) => _selectedIds.contains(conversation.id))
        .toList(growable: false);

    if (selected.isEmpty) return;

    Navigator.pop(context, selected);
  }
}

class _ForwardConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final bool selected;
  final VoidCallback onTap;

  const _ForwardConversationTile({
    required this.conversation,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,
      leading: AppCircularAvatar(
        name: conversation.displayName,
        imageUrl: conversation.avatar,
        radius: 24,
        backgroundColor: colors.chatCardColor,
        textColor: colors.white,
      ),
      title: Text(
        conversation.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.bodyStrong,
      ),
      subtitle: Text(
        conversation.lastMessage ?? AppLocalizations.of(context).chat_no_messages_yet,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.p.copyWith(color: colors.textMuted),
      ),
      trailing: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? colors.primary : Colors.transparent,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: 2,
          ),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 18, color: colors.white)
            : null,
      ),
    );
  }
}

class _ForwardPickerBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSend;

  const _ForwardPickerBottomBar({
    required this.selectedCount,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final label = selectedCount == 1
        ? l10n.chat_forward_to_one_chat
        : l10n.chat_forward_to_chats_count(selectedCount);

    return Container(
      key: ValueKey(selectedCount),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onSend,
          icon: const Icon(Icons.send_rounded),
          label: Text(label),
        ),
      ),
    );
  }
}

class _ForwardPickerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ForwardPickerEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: colors.textMuted),
            const SizedBox(height: 14),
            Text(title, textAlign: TextAlign.center, style: context.bodyStrong),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.p.copyWith(color: colors.textMuted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
