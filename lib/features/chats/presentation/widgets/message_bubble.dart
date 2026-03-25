import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/features/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/chats/presentation/widgets/attachment_grid.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final bgColor = isMe ? colors.blue : colors.border;

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
                style: TextStyle(color: isMe ? colors.white : colors.black),
              ),

            if (message.attachments.isNotEmpty)
              AttachmentGrid(attachments: message.attachments),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? colors.white : colors.black,
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
      return Icon(Icons.done_all, size: 14, color: colors.white);
    }
    if (message.deliveredAt != null) {
      return Icon(Icons.done_all, size: 14, color: colors.white);
    }
    return Icon(Icons.check, size: 14, color: colors.white);
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
