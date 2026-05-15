import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/sellers/domain/storefront_post.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/post_metric.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/my_storefront/post_thumbnail.dart';

class MyPostTile extends StatelessWidget {
  const MyPostTile({super.key, required this.post, required this.onMenuTap});

  final StorefrontPost post;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          PostThumbnail(
            imageUrl: post.imageUrl,
            duration: post.duration,
            isLive: post.isLive,
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
                const SizedBox(height: 5),
                Text(post.age, style: context.small),
                const SizedBox(height: 6),
                Row(
                  children: [
                    PostMetric(
                      icon: Icons.remove_red_eye_outlined,
                      label: post.views,
                    ),
                    const SizedBox(width: 8),
                    PostMetric(
                      icon: Icons.favorite_border_rounded,
                      label: post.likes,
                    ),
                    const SizedBox(width: 8),
                    PostMetric(
                      icon: Icons.chat_bubble_outline,
                      label: post.comments,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.more_vert, size: 20),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
