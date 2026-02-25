import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class AdCard extends ConsumerWidget {
  const AdCard({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  static const double _cardHeight = 285;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final subtitle = [
      if (ad.locationName.isNotEmpty) ad.locationName,
      if (ad.country.isNotEmpty) ad.country,
    ].join(', ');

    final hasOffer = ad.isOfferActive && ad.offerPercent > 0;

    final wishlistState = ref.watch(wishlistControllerProvider).value;
    final wish = wishlistState?.ids.contains(ad.id) ?? false;
    final pending = wishlistState?.pending.contains(ad.id) ?? false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: _cardHeight,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: ad.coverImage.isEmpty
                        ? Container(
                            color: colors.surface,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.border,
                            ),
                          )
                        : Image.network(
                            buildFileUrl(ad.coverImage) ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),

                  /// OFFER BADGE
                  if (hasOffer)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "-${ad.offerPercent.toStringAsFixed(0)}%",
                          style: context.p.copyWith(
                            color: colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  /// WISHLIST
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Material(
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
                        child: Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: pending
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
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
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// TITLE
            Text(
              ad.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.pStrong.copyWith(fontSize: 16),
            ),

            const SizedBox(height: 4),

            /// LOCATION
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.pMuted,
              ),

            const SizedBox(height: 8),

            /// PRICE
            _buildPriceSection(context),

            const Spacer(),

            /// RATING
            buildRatingRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final colors = context.appColors;
    final isService = ad.priceUnit.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Current Price (offer or normal)
        Text(priceText(ad), style: context.pStrong.copyWith(fontSize: 16)),

        /// Old Original Price (strikethrough)
        if (ad.hasActiveOffer && ad.price != null)
          Text(
            formattedOriginalPrice(ad),
            style: context.pMuted.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),

        /// Service unit
        if (isService)
          Text(
            "per ${ad.priceUnit}",
            style: context.p.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget buildRatingStars({
    required double rating,
    required Color color,
    double size = 16,
  }) {
    final stars = <Widget>[];

    for (int i = 1; i <= 5; i++) {
      if (rating >= i) {
        stars.add(Icon(Icons.star, size: size, color: color));
      } else if (rating >= i - 0.5) {
        stars.add(Icon(Icons.star_half, size: size, color: color));
      } else {
        stars.add(Icon(Icons.star_border, size: size, color: color));
      }
    }

    return Row(children: stars);
  }

  Widget buildRatingRow(BuildContext context) {
    final colors = context.appColors;

    if (ad.totalReviews == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        buildRatingStars(rating: ad.averageRating, color: colors.warning),
        const SizedBox(width: 6),
        Text('(${humanizeCount(ad.totalReviews)})', style: context.pMuted),
      ],
    );
  }
}
