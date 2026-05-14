import 'dart:io';

import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

class MediaImageTile extends StatelessWidget {
  final AdMediaImage image;
  final bool isPrimary;
  final bool showPrimaryOption;
  final File? localPreviewFile;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkPrimary;
  final VoidCallback? onEdit;

  const MediaImageTile({
    super.key,
    required this.image,
    required this.isPrimary,
    required this.showPrimaryOption,
    this.localPreviewFile,
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
            child: localPreviewFile != null
                ? Image.file(
                    localPreviewFile!,
                    key: ValueKey(localPreviewFile!.path),
                    fit: BoxFit.cover,
                    width: 110,
                    height: 110,
                  )
                : url == null
                ? Container(
                    color: colors.border,
                    child: const Icon(Icons.image_not_supported),
                  )
                : Image.network(
                    url,
                    key: ValueKey(url),
                    fit: BoxFit.cover,
                    width: 110,
                    height: 110,
                    gaplessPlayback: true,
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
                color: colors.white,
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
                      child: Row(
                        children: [
                          Icon(Icons.star_border, size: 18),
                          SizedBox(width: 10),
                          Text('Make cover photo'),
                        ],
                      ),
                    ),

                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),

                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      height: 36,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Delete',
                            style: context.p.copyWith(color: colors.primary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // -------- PRIMARY BADGE --------
          if (isPrimary)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Center(
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
            ),
        ],
      ),
    );
  }
}
