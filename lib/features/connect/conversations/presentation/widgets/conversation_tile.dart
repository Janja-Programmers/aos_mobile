import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';

import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';

import 'package:africaonlinestores/shared/utils/format_time.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  final bool isOnline;
  final bool isTyping;
  final DateTime? lastSeen;
  final VoidCallback? onLongPress;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isOnline = false,
    this.isTyping = false,
    this.lastSeen,
    this.onLongPress,
  });

  Color _avatarColor(BuildContext context) {
    final appColors = context.appColors;

    final colors = [
      appColors.red,
      appColors.success,
      appColors.orange,
      appColors.chatCardColor,
    ];

    return colors[conversation.displayName.hashCode % colors.length];
  }

  Widget _buildSubtitle(BuildContext context) {
    final colors = context.appColors;

    if (isTyping) {
      return Text(
        'Typing...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.success, fontStyle: FontStyle.italic),
      );
    }

    final message = conversation.lastMessage ?? '';
    final isMine =
        conversation.lastSender != conversation.user &&
        conversation.lastSender != 'Administrator';


    if (!isMine) {
      return Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.textMuted),
      );
    }

    return Row(
      children: [
        _buildMessageStatusIcon(context),
        const SizedBox(width: 4),
        Text(
          'You: ',
          style: TextStyle(
            color: colors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageStatusIcon(BuildContext context) {
    final colors = context.appColors;

    final isRead = conversation.lastMessageReadAt != null;
    final isDelivered = conversation.lastMessageDeliveredAt != null;

    if (isRead) {
      return Icon(Icons.done_all_rounded, size: 16, color: colors.primary);
    }

    if (isDelivered) {
      return Icon(Icons.done_all_rounded, size: 16, color: colors.textMuted);
    }

    return Icon(Icons.check_rounded, size: 16, color: colors.textMuted);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,

      // -------------------------
      // AVATAR
      // -------------------------
      leading: Stack(
        children: [
          AppCircularAvatar(
            name: conversation.displayName,
            imageUrl: conversation.avatar,
            radius: 24,
            backgroundColor: _avatarColor(context),
            textColor: colors.white,
          ),

          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),

      // -------------------------
      // TITLE
      // -------------------------
      title: Text(
        conversation.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.bodyStrong,
      ),

      // -------------------------
      // SUBTITLE
      // -------------------------
      subtitle: _buildSubtitle(context),

      // -------------------------
      // TRAILING (time + unread)
      // -------------------------
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              formatTime(conversation.lastMessageAt!),
              style: context.p.copyWith(
                fontSize: 12,
                color: conversation.unreadCount > 0
                    ? colors.primary
                    : colors.textMuted,
              ),
            ),

          if (conversation.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 8, // 🔥 improved spacing
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 24),
              child: Text(
                _formatUnread(conversation.unreadCount),
                textAlign: TextAlign.center,
                style: context.p.copyWith(
                  color: colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatUnread(int count) {
    if (count > 99) return '99+';
    return count.toString();
  }
}
