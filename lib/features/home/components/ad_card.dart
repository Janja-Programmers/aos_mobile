import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/home/utils/helpers.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class AdCard extends StatelessWidget {
  const AdCard({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final subtitle = [
      if (ad.locationName.isNotEmpty) ad.locationName,
      if (ad.country.isNotEmpty) ad.country,
    ].join(', ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 🔑 critical for grids & slivers
          children: [
            // ───────── Image ─────────
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : 120.0; // fallback safety

                  return SizedBox(
                    width: size,
                    height: size,
                    child: ad.coverImage.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.08),
                            child: const Icon(Icons.image_outlined),
                          )
                        : Image.network(
                            toFullUrl(ad.coverImage),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              alignment: Alignment.center,
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.08),
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // ───────── Title ─────────
            Text(
              ad.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.pStrong,
            ),

            // ───────── Location ─────────
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.p,
              ),
            ],

            const SizedBox(height: 2),

            // ───────── Price ─────────
            Text(
              priceText(ad),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
