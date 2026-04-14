import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/utils/format_time.dart';

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

  bool get _hasAvatar =>
      conversation.avatar != null && conversation.avatar!.isNotEmpty;

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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final subtitleText = isTyping
        ? "Typing..."
        : (conversation.lastMessage ?? '');

    final subtitleStyle = isTyping
        ? TextStyle(color: colors.success, fontStyle: FontStyle.italic)
        : TextStyle(color: colors.textMuted);

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,

      // -------------------------
      // AVATAR
      // -------------------------
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _hasAvatar ? colors.border : _avatarColor(context),
            backgroundImage: _hasAvatar
                ? NetworkImage(conversation.avatar!)
                : null,
            child: !_hasAvatar
                ? Text(
                    conversation.displayName.isNotEmpty
                        ? conversation.displayName[0].toUpperCase()
                        : "?",
                    style: context.bodyStrong.copyWith(color: colors.white),
                  )
                : null,
          ),

          // 🟢 Online indicator
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isOnline ? colors.success : colors.border,
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
      subtitle: Text(
        subtitleText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: subtitleStyle,
      ),

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
    if (count > 99) return "99+";
    return count.toString();
  }
}
