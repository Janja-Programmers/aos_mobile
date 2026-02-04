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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: ad.coverImage.isEmpty
                    ? Container(
                        color: Theme.of(context).dividerColor.withOpacity(0.08),
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.network(
                        toFullUrl(ad.coverImage),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.08),
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // ✅ Don't force this area to take remaining height (Expanded) —
            // it can be too small in a grid tile and overflow.
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    maxLines: 1, // ✅ tighter to avoid overflow
                    overflow: TextOverflow.ellipsis,
                    style: context.pStrong,
                  ),

                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2), // ✅ tighter spacing
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.p,
                    ),
                  ],

                  const SizedBox(height: 2),

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
          ],
        ),
      ),
    );
  }
}
