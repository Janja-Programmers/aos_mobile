import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_screen/common/chat_action_tile.dart';

class MessageActionsSheet extends StatelessWidget {
  const MessageActionsSheet({
    super.key,
    required this.message,
    required this.isMe,
    required this.canEdit,
    required this.onReply,
    required this.onEdit,
    required this.onToggleStar,
    required this.onToggleReaction,
    required this.onTranslate,
    required this.onForward,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
  });

  final ChatMessage message;
  final bool isMe;
  final bool canEdit;

  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onToggleStar;
  final ValueChanged<String> onToggleReaction;
  final VoidCallback onTranslate;
  final VoidCallback onForward;
  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForEveryone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChatActionTile(
            icon: Icons.reply_rounded,
            label: 'Reply',
            onTap: onReply,
          ),

          if (isMe && !message.isDeletedType && canEdit)
            ChatActionTile(
              icon: Icons.edit_outlined,
              label: 'Edit',
              onTap: onEdit,
            ),

          if (!message.isDeletedType)
            ChatActionTile(
              icon: message.isStarred
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              label: message.isStarred ? 'Unstar' : 'Star',
              onTap: onToggleStar,
            ),

          if (!message.isDeletedType)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['👍', '❤️', '😂', '😮', '🙏'].map((emoji) {
                  final selected = message.myReaction == emoji;

                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => onToggleReaction(emoji),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primary.withOpacity(0.14)
                            : colors.elevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? colors.primary : colors.border,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
            ),

          if (!message.isDeletedType)
            ChatActionTile(
              icon: Icons.translate_rounded,
              label: 'Translate',
              onTap: onTranslate,
            ),

          if (!message.isDeletedType)
            ChatActionTile(
              icon: Icons.shortcut_rounded,
              label: 'Forward',
              onTap: onForward,
            ),

          ChatActionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete for me',
            destructive: true,
            onTap: onDeleteForMe,
          ),

          if (isMe && !message.isDeletedType)
            ChatActionTile(
              icon: Icons.delete_forever_outlined,
              label: 'Delete for everyone',
              destructive: true,
              onTap: onDeleteForEveryone,
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
