import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class AdListItem extends ConsumerWidget {
  const AdListItem({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final price = buildPriceDisplay(ad);
    final isService = ad.priceUnit.isNotEmpty;

    final wishlistState = ref.watch(wishlistControllerProvider).value;
    final wish = wishlistState?.ids.contains(ad.id) ?? false;
    final pending = wishlistState?.pending.contains(ad.id) ?? false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
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
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "-${ad.offerPercent}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            /// INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.p.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),

                  if (price.show) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          price.current!,
                          style: context.body.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (price.original != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            price.original!,
                            style: context.body.copyWith(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (isService) ...[
                          const SizedBox(width: 6),
                          Text(
                            "per ${ad.priceUnit}",
                            style: context.p.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  if (ad.totalReviews > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "${ad.averageRating} (${ad.totalReviews})",
                          style: context.pMuted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            /// WISHLIST
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: pending
                    ? null
                    : () async {
                        final ok = await ref
                            .read(wishlistControllerProvider.notifier)
                            .toggle(ad.id);

                        if (!ok) {
                          if (!context.mounted) return;
                          ShowSnack(
                            context,
                            'Unexpected error. Please try again.',
                          ).error();
                        }
                      },
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: pending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            wish ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: wish ? colors.primary : colors.textPrimary,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
