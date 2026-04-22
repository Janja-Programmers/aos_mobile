import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';

import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';

class ShortGridCard extends StatelessWidget {
  final ShortModel short;
  final int index;

  const ShortGridCard({super.key, required this.short, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final caption = short.caption;

    final imageUrl = short.thumbnailUrl;

    return GestureDetector(
      onTap: () {
        ShortsNavigation.toShorts(context, initialIndex: index);
        appLogger.i("ShortGridCard | onTap Index: $index");
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 Thumbnail (NO fixed height → Masonry magic)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(colors),
              ),
            ),

            /// 📝 Caption
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),

            /// ❤️ Metrics
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.favorite, size: 14, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _formatCount(10000),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(AppColorTokens colors) {
    return Container(
      height: 150,
      color: colors.border,
      child: const Center(child: Icon(Icons.play_arrow)),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}
