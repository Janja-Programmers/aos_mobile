import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';

class ShortEntityGridCard extends StatelessWidget {
  final Short short;
  final int index;

  const ShortEntityGridCard({
    super.key,
    required this.short,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: () => ShortsNavigation.toShorts(context, initialIndex: index),
      child: Container(
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.78,
              child: Image.network(
                short.thumbnailUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(colors),
              ),
            ),
            if (short.caption.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 2),
                child: Text(
                  short.caption.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      short.sellerShopName ?? 'Shop',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    short.metrics.likeCount.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.thumb_up_alt_outlined, size: 13),
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
      width: double.infinity,
      color: colors.border,
      child: const Center(child: Icon(Icons.play_arrow)),
    );
  }
}
