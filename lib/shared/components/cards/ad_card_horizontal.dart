import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class AdHorizontalCard extends StatelessWidget {
  const AdHorizontalCard({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final price = buildPriceDisplay(ad);
    final isService = ad.priceUnit.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ad.primaryImage.isEmpty
                        ? Container(
                            color: colors.elevated,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.textMuted,
                            ),
                          )
                        : Image.network(
                            buildFileUrl(ad.primaryImage) ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: colors.elevated,
                              child: Icon(
                                Icons.image_outlined,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                  ),
                ),

                /// OFFER BADGE
                if (ad.hasActiveOffer)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "-${ad.offerPercent}%",
                        style: TextStyle(
                          color: colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              ad.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.pStrong.copyWith(fontSize: 14),
            ),

            if (price.show) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(  
                    price.current!,
                    style: context.body.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (price.original != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      price.original!,
                      style: context.body.copyWith(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              if (isService)
                Text(
                  ad.priceUnit,
                  style: context.p.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.primary,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
