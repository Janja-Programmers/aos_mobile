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

    final price = resolveAdPrice(ad);
    final isService = ad.priceUnit.isNotEmpty;
    final imageUrl = buildFileUrl(ad.primaryImage);

    final wishlistState = ref.watch(wishlistControllerProvider).value;
    final wish = wishlistState?.ids.contains(ad.id) ?? false;
    final pending = wishlistState?.pending.contains(ad.id) ?? false;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? Container(
                            color: colors.elevated,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.textMuted,
                            ),
                          )
                        : Image.network(
                            imageUrl,
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

                /// WISHLIST
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: pending
                          ? null
                          : () async {
                              final ok = await ref
                                  .read(wishlistControllerProvider.notifier)
                                  .toggle(ad.id);

                              if (!ok && context.mounted) {
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
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  wish ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: wish
                                      ? colors.primary
                                      : colors.textPrimary,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// OFFER BADGE
                if (ad.isOfferActive)
                  Positioned(
                    top: 8,
                    left: 8,
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
                        style: TextStyle(
                          color: colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            /// INFO
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    ad.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.p.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// LOCATION
                  Text(
                    "${ad.locationName}, ${ad.country}",
                    style: context.pMuted.copyWith(fontSize: 11),
                  ),

                  const SizedBox(height: 6),

                  /// PRICE
                  if (price.show)
                    Row(
                      children: [
                        Text(
                          price.current ?? '',
                          style: context.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
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

                  /// SERVICE UNIT
                  if (isService) ...[
                    const SizedBox(height: 2),
                    Text(
                      ad.priceUnit,
                      style: context.p.copyWith(
                        fontSize: 11,
                        color: colors.primary,
                      ),
                    ),
                  ],

                  /// REVIEWS
                  if (ad.totalReviews > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "${ad.averageRating} (${humanizeCount(ad.totalReviews)})",
                          style: context.pMuted.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
