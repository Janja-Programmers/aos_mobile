import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class ChatAdPreview extends StatelessWidget {
  const ChatAdPreview({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onClose,
  });

  final String title;
  final String price;
  final String? imageUrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imagePath = buildFileUrl(imageUrl);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              color: colors.border.withOpacity(0.3),
              child: (imagePath == null || imagePath.isEmpty)
                  ? Icon(
                      Icons.image_outlined,
                      color: colors.textMuted,
                      size: 22,
                    )
                  : Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.broken_image_outlined,
                        color: colors.textMuted,
                        size: 22,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 10),

          /// TITLE + PRICE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.pStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  price,
                  style: context.p.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          /// CLOSE BUTTON
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.border.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
