import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/presentation/live_l10n.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class LiveInputBar extends StatelessWidget {
  const LiveInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
    this.replyTo,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final LiveComment? replyTo;
  final VoidCallback? onCancelReply;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final target = replyTo;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPositionedDirectional(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      start: 0,
      end: 0,
      bottom: keyboardInset,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 6, 10, keyboardInset > 0 ? 6 : 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.black.withValues(alpha: .78),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.white.withValues(alpha: .16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (target != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 6, 0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.reply_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.l10n.liveReplyingTo(target.authorLabel),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.p.copyWith(color: Colors.white70),
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.liveCancel,
                          onPressed: onCancelReply,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('live_comment_input'),
                        controller: controller,
                        enabled: !isSending,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 500,
                        textInputAction: TextInputAction.newline,
                        style: context.p.copyWith(color: colors.white),
                        decoration: InputDecoration(
                          hintText: target == null
                              ? context.l10n.liveCommentHint
                              : context.l10n.liveReplyHint,
                          hintStyle: context.p.copyWith(color: Colors.white54),
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                            14,
                            12,
                            6,
                            12,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: IconButton.filled(
                        tooltip: target == null
                            ? context.l10n.liveCommentHint
                            : context.l10n.liveReply,
                        onPressed: isSending ? null : onSend,
                        icon: isSending
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.white,
                                ),
                              )
                            : Icon(Icons.send_rounded, color: colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
