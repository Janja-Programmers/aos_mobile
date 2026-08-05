import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_background.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_date_separator.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/utils/format_time.dart';
import 'package:flutter/material.dart';

class ChatMessagesView extends StatelessWidget {
  final ChatMessagesState messagesState;
  final ScrollController scrollController;
  final String currentUserId;
  final String conversationId;
  final String otherUserId;
  final String otherDisplayName;
  final String? otherAvatarUrl;
  final ChatLocalPreferencesState preferences;
  final ValueChanged<ChatMessage> onReply;
  final void Function(ChatMessage message, bool isMe, Offset anchor)
  onLongPress;
  final ValueChanged<ChatMessage> onRetry;
  final VoidCallback onRetryInitial;
  final VoidCallback onRetryOlder;

  const ChatMessagesView({
    super.key,
    required this.messagesState,
    required this.scrollController,
    required this.currentUserId,
    required this.conversationId,
    required this.otherUserId,
    required this.otherDisplayName,
    required this.otherAvatarUrl,
    required this.preferences,
    required this.onReply,
    required this.onLongPress,
    required this.onRetry,
    required this.onRetryInitial,
    required this.onRetryOlder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ChatBackground(
      patternAssetPath: 'assets/images/chat_pattern.png',
      preferences: preferences,
      child: _buildContent(context, colors),
    );
  }

  bool _shouldShowDateSeparator({
    required List<ChatMessage> messages,
    required int index,
  }) {
    if (index == messages.length - 1) {
      return true;
    }

    final currentDate = messages[index].createdAt.toLocal();
    final olderDate = messages[index + 1].createdAt.toLocal();

    return !_isSameCalendarDay(currentDate, olderDate);
  }

  bool _isSameCalendarDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Widget _buildContent(BuildContext context, AppColorTokens colors) {
    final l10n = AppLocalizations.of(context);
    if (messagesState.isInitialLoading && messagesState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesState.hasError && messagesState.messages.isEmpty) {
      return _MessageStateView(
        icon: Icons.cloud_off_rounded,
        title: l10n.chat_could_not_load_messages,
        message: l10n.chat_check_connection_try_again,
        actionLabel: l10n.chat_retry,
        onAction: onRetryInitial,
      );
    }

    final messages = messagesState.messages;
    if (messages.isEmpty) {
      return _MessageStateView(
        icon: Icons.chat_bubble_outline_rounded,
        title: l10n.chat_no_messages_yet,
        message: l10n.chat_no_messages_hint,
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isSystem = message.isSystemMessage;

            final isMe =
                !isSystem &&
                isMessageOwnedBy(
                  message: message,
                  authenticatedCanonicalId: currentUserId,
                );

            final showDateSeparator = _shouldShowDateSeparator(
              messages: messages,
              index: index,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDateSeparator)
                  ChatDateSeparator(
                    label: formatDateGroupTitle(message.createdAt),
                  ),
                Dismissible(
                  key: ValueKey(
                    'reply-${message.id}-${message.createdAt.microsecondsSinceEpoch}',
                  ),
                  direction: isSystem || message.isDeletedType
                      ? DismissDirection.none
                      : DismissDirection.startToEnd,
                  confirmDismiss: (direction) async {
                    onReply(message);
                    return false;
                  },
                  background: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Icon(Icons.reply_rounded, color: colors.primary),
                    ),
                  ),
                  child: MessageBubble(
                    message: message,
                    isMe: isMe,
                    isSystem: isSystem,
                    conversationId: conversationId,
                    otherUserId: otherUserId,
                    otherDisplayName: otherDisplayName,
                    otherAvatarUrl: otherAvatarUrl,
                    onLongPress: (anchor) => onLongPress(message, isMe, anchor),
                    onRetry: message.isLocalFailed
                        ? () => onRetry(message)
                        : null,
                    onAdTap: (adId) {
                      AdNavigation.toDetail(context, adId);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        if (messagesState.hasError)
          PositionedDirectional(
            top: 8,
            start: 16,
            end: 16,
            child: Material(
              color: colors.elevated,
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.chat_older_messages_load_failed,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: onRetryOlder,
                      child: Text(l10n.chat_retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (messagesState.isLoadingMore)
          const Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _MessageStateView extends StatelessWidget {
  const _MessageStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
