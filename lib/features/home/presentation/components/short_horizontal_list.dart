import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';

class ShortsHorizontalList extends StatelessWidget {
  const ShortsHorizontalList({super.key, required this.shorts});

  final List<Short> shorts;

  @override
  Widget build(BuildContext context) {
    if (shorts.isEmpty) {
      return const SizedBox(height: 260);
    }

    return SizedBox(
      height: 260,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: shorts.length,

        separatorBuilder: (_, _) => const SizedBox(width: 12),

        itemBuilder: (context, index) {
          final short = shorts[index];

          return _ShortPreviewCard(short: short, shorts: shorts, index: index);
        },
      ),
    );
  }
}

class _ShortPreviewCard extends StatelessWidget {
  const _ShortPreviewCard({
    required this.short,
    required this.shorts,
    required this.index,
  });

  final Short short;
  final List<Short> shorts;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final thumbnailUrl = buildFileUrl(short.thumbnailUrl);

    return GestureDetector(
      onTap: () {
        ShortsNavigation.toShortDetail(
          context,
          initialShorts: List<Short>.from(shorts),
          initialIndex: index,
          initialNextCursor: null,
          initialHasMore: false,
        );
      },
      child: SizedBox(
        width: 140,
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Container(
                            color: colors.black,
                            child: const Icon(Icons.play_arrow),
                          );
                        },
                      ),
                      Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
