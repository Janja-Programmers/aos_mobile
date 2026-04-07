import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/shared/components/rating_display.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';

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
          maxLines: 1,
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
              Flexible(
                child: Text(
                  price.current ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              if (isService)
                Flexible(
                  child: Text(
                    ad.priceUnit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.p.copyWith(
                      fontSize: 11.5,
                      color: colors.primary,
                    ),
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

        RatingDisplay(rating: ad.averageRating, reviewCount: ad.totalReviews),
      ],
    );
  }
}
