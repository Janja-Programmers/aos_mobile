import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/sellers/domain/storefront_post.dart';
import 'package:flutter/material.dart';

class TopPerformingPostTile extends StatelessWidget {
  const TopPerformingPostTile({super.key, required this.post});

  final StorefrontPost post;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageUri = post.imageUrl?.trim();
    final imageUrl = buildFileUrl(imageUri);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(10),
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.image_outlined, size: 22, color: colors.border)
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.small.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${post.views} views',
                  style: context.small.copyWith(
                    color: colors.border,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${post.likes} likes',
            style: context.small.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
