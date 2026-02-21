import 'package:flutter/material.dart';

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
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: 110,
                    height: 110,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
          ),

          // -------- 3 DOT MENU --------
          Positioned(
            top: 4,
            right: 2,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
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

          // -------- PRIMARY BADGE --------
          if (isPrimary)
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
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
