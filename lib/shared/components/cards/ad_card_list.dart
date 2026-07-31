import 'dart:async';

import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    final isAuth = ref.watch(isAuthenticatedProvider);

    final wishlistState = isAuth ? ref.watch(wishlistControllerProvider) : null;

    final wish =
        wishlistState?.resolve(ad.id, fallback: ad.isWishlisted) ?? false;
    final pending = wishlistState?.pending.contains(ad.id) ?? false;

    Future<void> toggleWishlist() async {
      final success = await ref
          .read(wishlistControllerProvider.notifier)
          .toggle(ad.id, currentValue: wish);

      if (!success && context.mounted) {
        ShowSnack(context, context.l10n.wishlist_update_error).error();
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? ColoredBox(
                            color: colors.elevated,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.textMuted,
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => ColoredBox(
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
                  child: Semantics(
                    button: true,
                    enabled: !pending,
                    label: wish
                        ? context.l10n.wishlist_remove
                        : context.l10n.wishlist_add,
                    child: Material(
                      color: colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: pending
                            ? null
                            : () {
                                unawaited(
                                  AppNavigation.requireAuth(
                                    context,
                                    ref,
                                    onAuthenticated: () {
                                      unawaited(toggleWishlist());
                                    },
                                  ),
                                );
                              },
                        child: SizedBox(
                          height: 48,
                          width: 48,
                          child: Center(
                            child: pending
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    wish
                                        ? Icons.favorite
                                        : Icons.favorite_border,
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
                        '-${ad.offerPercent}%',
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
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
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
                    '${ad.locationName}, ${ad.country}',
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
                        Icon(Icons.star, size: 14, color: colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${ad.averageRating} (${humanizeCount(ad.totalReviews)})',
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
