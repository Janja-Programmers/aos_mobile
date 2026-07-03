import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter/material.dart';

class ReplyComposerPreview extends StatelessWidget {
  const ReplyComposerPreview({
    super.key,
    required this.message,
    required this.onClose,
  });

  final ChatMessage message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final title = message.senderDisplayName ?? message.sender;

    final body = message.hasText
        ? message.visibleText
        : message.hasAd
        ? 'Ad preview'
        : message.hasAttachments
        ? 'Attachment'
        : 'Message';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: colors.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
