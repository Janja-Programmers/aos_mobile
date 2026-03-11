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
        Flexible(
          child: Text(
            ad.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.pStrong.copyWith(fontSize: 13),
          ),
        ),
        const SizedBox(height: 3),

        Text(
          "${ad.locationName}, ${ad.country}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.pMuted.copyWith(fontSize: 12),
        ),

        const SizedBox(height: 3),

        if (price.show) ...[
          Text(
            price.current ?? '',
            style: context.body.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),

          if (price.original != null && price.original!.isNotEmpty)
            Text(
              price.original!,
              style: context.body.copyWith(
                fontSize: 12,
                decoration: TextDecoration.lineThrough,
                color: colors.textMuted,
              ),
            ),

          if (isService)
            Text(
              ad.priceUnit,
              style: context.p.copyWith(fontSize: 11, color: colors.primary),
            ),
        ],

        const SizedBox(height: 3),

        Row(
          children: [
            Icon(Icons.star, size: 14, color: colors.amber),
            const SizedBox(width: 4),
            Text(
              "${ad.averageRating} (${humanizeCount(ad.totalReviews)})",
              style: context.pMuted.copyWith(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
