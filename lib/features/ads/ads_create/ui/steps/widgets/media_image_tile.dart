import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

class MediaImageTile extends StatelessWidget {
  final AdMediaImage image;
  final bool isPrimary;
  final bool showPrimaryOption;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkPrimary;
  final VoidCallback? onEdit;

  const MediaImageTile({
    super.key,
    required this.image,
    required this.isPrimary,
    required this.showPrimaryOption,
    this.onDelete,
    this.onMarkPrimary,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final url = buildFileUrl(image.url);
    final colors = context.appColors;

    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        children: [
          // -------- IMAGE --------
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: url == null
                ? Container(
                    color: colors.border,
                    child: const Icon(Icons.image_not_supported),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: 110,
                    height: 110,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.border,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
          ),

          // -------- 3 DOT MENU --------
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colors.white, size: 18),
                padding: EdgeInsets.zero,
                splashRadius: 18,
                constraints: const BoxConstraints(minWidth: 140),
                onSelected: (value) {
                  if (value == 'primary') onMarkPrimary?.call();
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => [
                  if (showPrimaryOption && onMarkPrimary != null)
                    const PopupMenuItem(
                      value: 'primary',
                      height: 36,
                      child: Text('Mark as primary'),
                    ),
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      height: 36,
                      child: Text('Edit'),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      height: 36,
                      child: Text('Delete'),
                    ),
                ],
              ),
            ),
          ),

          // -------- PRIMARY BADGE --------
          if (isPrimary)
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Cover',
                  style: TextStyle(
                    color: colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
