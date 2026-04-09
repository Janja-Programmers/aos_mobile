import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class CommentsList extends StatelessWidget {
  const CommentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: 10, // 🔥 replace with API later
      itemBuilder: (_, index) {
        return const _CommentItem();
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.surface.withOpacity(0.5),
            child: Text("F", style: context.p.copyWith(color: colors.white)),
          ),

          const SizedBox(width: 10),

          // 💬 Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@fashionlover",
                  style: context.p.copyWith(
                    color: colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "This is amazing! 🔥",
                  style: context.p.copyWith(color: colors.white),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      "2h",
                      style: context.p.copyWith(
                        color: colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Text(
                      "Reply",
                      style: context.p.copyWith(
                        color: colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ❤️ Like
          Column(
            children: [
              const Icon(Icons.favorite_border, size: 20),
              const SizedBox(height: 4),
              Text("234", style: context.p.copyWith(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
