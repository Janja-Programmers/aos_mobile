import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';

class AdCardBody extends StatelessWidget {
  const AdCardBody({super.key, required this.ad});

  final AOSAdListItem ad;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isService = ad.priceUnit.isNotEmpty;
    final price = resolveAdPrice(ad);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ad.title,
          overflow: TextOverflow.ellipsis,
          style: context.pStrong.copyWith(fontSize: 13),
        ),

        const SizedBox(height: 2),

        Text(
          "${ad.locationName}, ${ad.country}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.pMuted.copyWith(fontSize: 11.5, height: 1.2),
        ),

        const SizedBox(height: 2),

        if (price.show) ...[
          Row(
            children: [
              Text(
                price.current ?? '',
                style: context.body.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),

              const SizedBox(width: 6),

              if (isService)
                Text(
                  ad.priceUnit,
                  style: context.p.copyWith(
                    fontSize: 11.5,
                    color: colors.primary,
                  ),
                ),
            ],
          ),

          if (price.original != null && price.original!.isNotEmpty)
            Text(
              price.original!,
              style: context.body.copyWith(
                fontSize: 11,
                decoration: TextDecoration.lineThrough,
                color: colors.textMuted,
              ),
            ),
        ],

        const SizedBox(height: 2),

        Row(
          children: [
            ..._buildStars(ad.averageRating, context),

            const SizedBox(width: 4),

            Text(
              "${ad.averageRating} (${humanizeCount(ad.totalReviews)})",
              style: context.pMuted.copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

List<Widget> _buildStars(double rating, BuildContext context) {
  final colors = context.appColors;
  const totalStars = 5;

  // If no rating → show all muted
  if (rating == 0) {
    return List.generate(
      totalStars,
      (_) => Icon(Icons.star_border, size: 14, color: colors.textMuted),
    );
  }

  final int fullStars = rating.floor();
  final bool hasHalfStar = (rating - fullStars) >= 0.5;

  return List.generate(totalStars, (index) {
    if (index < fullStars) {
      return Icon(Icons.star, size: 12, color: colors.amber);
    } else if (index == fullStars && hasHalfStar) {
      return Icon(Icons.star_half, size: 12, color: colors.amber);
    } else {
      return Icon(Icons.star_border, size: 12, color: colors.textMuted);
    }
  });
}
