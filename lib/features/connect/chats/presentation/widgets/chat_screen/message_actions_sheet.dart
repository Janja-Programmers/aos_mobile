import 'dart:math' as math;

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
    final media = MediaQuery.of(context);
    final colors = context.appColors;

    final maxHeight = math.max(
      220.0,
      media.size.height * 0.82 - media.viewInsets.bottom,
    );

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),

                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),

                const SizedBox(height: 8),

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      runAlignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: ['👍', '❤️', '😂', '😮', '🙏'].map((emoji) {
                        final selected = message.myReaction == emoji;

                        return InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => onToggleReaction(emoji),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? colors.primary.withOpacity(0.14)
                                  : colors.elevated,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? colors.primary
                                    : colors.border,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                if (!message.isDeletedType)
                  ChatActionTile(
                    icon: Icons.translate_rounded,
                    label: message.hasTranslation
                        ? 'Translate again'
                        : 'Translate',
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
          ),
        ),
      ),
    );
  }
}
