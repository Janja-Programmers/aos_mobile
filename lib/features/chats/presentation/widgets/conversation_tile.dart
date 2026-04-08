import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/chats/domain/chat_conversation.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  // 🔥 NEW
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final subtitleText = isTyping
        ? "Typing..."
        : (conversation.lastMessage ?? '');

    final subtitleStyle = isTyping
        ? const TextStyle(color: Colors.green, fontStyle: FontStyle.italic)
        : null;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: conversation.avatar != null
                ? NetworkImage(conversation.avatar!)
                : null,
            backgroundColor: colors.border,
            child: conversation.avatar == null
                ? Text(
                    conversation.displayName.isNotEmpty
                        ? conversation.displayName[0]
                        : "?",
                    style: context.bodyStrong,
                  )
                : null,
          ),

          // 🟢 Online indicator
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),

      title: Text(
        conversation.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.bodyStrong,
      ),

      subtitle: Text(
        subtitleText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: subtitleStyle,
      ),

      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              _formatTime(conversation.lastMessageAt!),
              style: TextStyle(
                fontSize: 12,
                color: conversation.unreadCount > 0
                    ? Colors.green
                    : Colors.grey,
              ),
            ),

          if (conversation.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                _formatUnread(conversation.unreadCount),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),

      onLongPress: onLongPress,
    );
  }

  // -----------------------------
  // Format time (smarter UX)
  // -----------------------------
  String _formatTime(DateTime dt) {
    final now = DateTime.now();

    if (now.difference(dt).inDays == 0) {
      return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } else if (now.difference(dt).inDays == 1) {
      return "Yesterday";
    } else {
      return "${dt.day}/${dt.month}";
    }
  }

  // -----------------------------
  // Format unread count
  // -----------------------------
  String _formatUnread(int count) {
    if (count > 99) return "99+";
    return count.toString();
  }
}
