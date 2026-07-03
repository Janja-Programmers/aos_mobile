import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_messages_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_background.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/chat_date_separator.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/message_bubble.dart';
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
  final void Function(ChatMessage message, bool isMe) onLongPress;
  final ValueChanged<ChatMessage> onRetry;

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
    if (messagesState.isInitialLoading && messagesState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesState.hasError && messagesState.messages.isEmpty) {
      return Center(child: Text(messagesState.error.toString()));
    }

    final messages = messagesState.messages;

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

            final isMe = _isOwnMessage(
              sender: message.sender,
              currentUserId: currentUserId,
              isSystem: isSystem,
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
                    onLongPress: () => onLongPress(message, isMe),
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

  bool _isOwnMessage({
    required String sender,
    required String currentUserId,
    required bool isSystem,
  }) {
    if (isSystem) return false;
    if (currentUserId.isEmpty) return false;
    return _normalizeUser(sender) == currentUserId;
  }

  static String _normalizeUser(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }
}
