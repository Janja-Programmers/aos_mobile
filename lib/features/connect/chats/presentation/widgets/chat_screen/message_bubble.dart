import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/attachment_grid.dart';
import 'package:africaonlinestores/features/connect/utils/format_time.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSystem = false,
  });

  final ChatMessage message;
  final bool isMe;
  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final bgColor = isMe ? colors.chatCardColor : colors.surface;

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            message.content ?? '',
            textAlign: TextAlign.center,
            style: context.p.copyWith(color: colors.textMuted, fontSize: 12),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message.content != null)
              Text(
                message.content!,
                style: TextStyle(
                  color: isMe ? colors.white : colors.textPrimary,
                ),
              ),

            if (message.attachments.isNotEmpty)
              AttachmentGrid(attachments: message.attachments),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.createdAt),
                  style: context.p.copyWith(
                    fontSize: 10,
                    color: isMe ? colors.white : colors.textPrimary,
                  ),
                ),
                if (isMe) const SizedBox(width: 4),
                if (isMe) _buildStatusIcon(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final colors = context.appColors;

    if (message.readAt != null) {
      return Icon(Icons.done_all, size: 14, color: colors.blue);
    }

    if (message.deliveredAt != null) {
      return Icon(Icons.check, size: 14, color: colors.success);
    }

    return Icon(Icons.done, size: 14, color: colors.white);
  }
}
