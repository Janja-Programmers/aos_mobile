import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/short_comment.dart';

class CommentMainRow extends StatelessWidget {
  final ShortComment comment;
  final VoidCallback onReplyTap;

  const CommentMainRow({
    super.key,
    required this.comment,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: colors.border,
          child: Text(
            comment.userId.isNotEmpty ? comment.userId[0].toUpperCase() : "U",
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@${comment.userId}",
                style: context.p.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(comment.comment, style: context.body),

              const SizedBox(height: 6),

              Row(
                children: [
                  Text(_formatTime(comment.createdAt)),
                  const SizedBox(width: 12),

                  // 🔥 TAP HERE
                  GestureDetector(
                    onTap: onReplyTap,
                    child: Text(
                      "Reply",
                      style: context.p.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(String raw) {
    try {
      final date = DateTime.parse(raw);
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return "now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m";
      if (diff.inHours < 24) return "${diff.inHours}h";
      return "${diff.inDays}d";
    } catch (_) {
      return "";
    }
  }
}
