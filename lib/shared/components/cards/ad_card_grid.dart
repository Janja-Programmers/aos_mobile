import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/home/shared/utils/helpers.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class AdGridCard extends ConsumerWidget {
  const AdGridCard({super.key, required this.ad, required this.onTap});

  final AOSAdListItem ad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final width = MediaQuery.of(context).size.width;
    final imageHeight = width < 360 ? 100.0 : 120.0;

    final subtitle = [
      if (ad.locationName.isNotEmpty) ad.locationName,
      if (ad.country.isNotEmpty) ad.country,
    ].join(', ');

    final isService = ad.priceUnit.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: ad.coverImage.isEmpty
                        ? Container(
                            color: colors.elevated,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.textMuted,
                            ),
                          )
                        : Image.network(
                            buildFileUrl(ad.coverImage) ?? '',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _GridWishlistButton(ad: ad),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// FLEXIBLE CONTENT AREA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// TOP TEXT BLOCK
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        ad.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.pStrong.copyWith(fontSize: 15),
                      ),

                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.p.copyWith(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  /// BOTTOM PRICE + RATING BLOCK
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      Text(
                        ad.priceDisplay,
                        style: context.body.copyWith(fontSize: 15),
                      ),

                      if (isService)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            ad.priceUnit,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.p.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colors.primary,
                            ),
                          ),
                        ),

                      if (ad.totalReviews > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < ad.averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 13,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${humanizeCount(ad.totalReviews)})",
                              style: context.pMuted.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ],
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

class _GridWishlistButton extends ConsumerWidget {
  const _GridWishlistButton({required this.ad});

  final AOSAdListItem ad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final wishlistState = ref.watch(wishlistControllerProvider).value;
    final wish = wishlistState?.ids.contains(ad.id) ?? false;
    final pending = wishlistState?.pending.contains(ad.id) ?? false;

    return Material(
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
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
          ),
          alignment: Alignment.center,
          child: pending
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              : Icon(
                  wish ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: wish ? colors.primary : colors.textPrimary,
                ),
        ),
      ),
    );
  }
}
