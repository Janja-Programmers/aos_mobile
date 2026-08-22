import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class ReplyPreview extends StatelessWidget {
  const ReplyPreview({
    super.key,
    required this.reply,
    required this.isMe,
    this.onTap,
  });

  final ChatReplyPreview reply;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final preview = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: isMe ? colors.white.withValues(alpha: 0.12) : colors.elevated,
        borderRadius: BorderRadius.circular(9),
        border: Border(
          left: BorderSide(
            color: isMe ? colors.white : colors.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.senderDisplayName ?? reply.sender,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.p.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isMe ? colors.white : colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reply.previewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.p.copyWith(
              fontSize: 12,
              color: isMe ? colors.white : colors.textMuted,
              fontStyle: reply.isDeleted ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return preview;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context).chat_view_replied_message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: preview,
      ),
    );
  }
}
