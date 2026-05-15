import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class PostActionsBottomSheet extends StatelessWidget {
  const PostActionsBottomSheet({
    super.key,
    required this.postTitle,
    required this.onViewAnalytics,
    required this.onEditPost,
    required this.onDeletePost,
  });

  final String postTitle;
  final VoidCallback onViewAnalytics;
  final VoidCallback onEditPost;
  final VoidCallback onDeletePost;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            postTitle,
            style: context.p.copyWith(fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          _SheetAction(
            icon: Icons.analytics_outlined,
            label: 'View Analytics',
            onTap: onViewAnalytics,
          ),
          _SheetAction(
            icon: Icons.edit_outlined,
            label: 'Edit Post',
            onTap: onEditPost,
          ),
          _SheetAction(
            icon: Icons.delete_outline,
            label: 'Delete Post',
            color: colors.primary,
            onTap: onDeletePost,
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? context.appColors.textPrimary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: context.p.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
