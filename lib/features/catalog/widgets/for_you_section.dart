import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class ForYouSection extends StatelessWidget {
  const ForYouSection({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    final w = MediaQuery.of(context).size.width;
    final cardWidth = (w * 0.40).clamp(140.0, 170.0);
    final listHeight = (w * 0.45).clamp(150.0, 185.0);

    return Column(
      children: [
        Row(
          children: [
            Text(
              'For you',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See all >',
                style: TextStyle(color: colors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Container(
                width: cardWidth,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: colors.border),
                              ),
                              child: Icon(
                                Icons.favorite_border,
                                size: 16,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Recommended item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
