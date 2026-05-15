import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_comment.dart';

class CommentMainRow extends StatelessWidget {
  final ShortComment comment;

  final VoidCallback onReplyTap;
  final VoidCallback? onToggleLike;
  final VoidCallback? onDelete;

  final bool isLikePending;
  final bool isDeletePending;

  const CommentMainRow({
    super.key,
    required this.comment,
    required this.onReplyTap,
    this.onToggleLike,
    this.onDelete,
    this.isLikePending = false,
    this.isDeletePending = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final canDelete = comment.canDelete || comment.isOwner;

    return Opacity(
      opacity: isDeletePending ? 0.45 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentAvatar(comment: comment),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: context.p.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(comment.comment, style: context.body),

                const SizedBox(height: 8),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    Text(
                      _formatTime(comment.createdAt),
                      style: context.p.copyWith(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),

                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onReplyTap,
                      child: Text(
                        'Reply',
                        style: context.p.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),

                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isLikePending ? null : onToggleLike,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: comment.isLiked
                                ? colors.primary
                                : colors.textSecondary,
                          ),
                          if (comment.likeCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              _formatCount(comment.likeCount),
                              style: context.p.copyWith(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (canDelete)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: isDeletePending ? null : onDelete,
                        child: Text(
                          isDeletePending ? 'Deleting...' : 'Delete',
                          style: context.p.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String raw) {
    try {
      final date = DateTime.parse(raw);
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';

      return '${diff.inDays}d';
    } catch (_) {
      return '';
    }
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _CommentAvatar extends StatelessWidget {
  final ShortComment comment;

  const _CommentAvatar({required this.comment});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatar = comment.avatar?.trim();

    return CircleAvatar(
      radius: 18,
      backgroundColor: colors.border,
      backgroundImage: avatar != null && avatar.isNotEmpty
          ? NetworkImage(avatar)
          : null,
      child: avatar == null || avatar.isEmpty
          ? Text(
              comment.authorName.isNotEmpty
                  ? comment.authorName[0].toUpperCase()
                  : 'U',
              style: context.p.copyWith(fontWeight: FontWeight.w700),
            )
          : null,
    );
  }
}
