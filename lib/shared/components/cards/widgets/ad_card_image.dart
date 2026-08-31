import 'dart:async';

import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdCardImage extends ConsumerWidget {
  const AdCardImage({super.key, required this.ad, required this.height});

  final AOSAdListItem ad;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final imageUrl = buildFileUrl(ad.primaryImage);

    final isAuth = ref.watch(isAuthenticatedProvider);

    final wishlistState = isAuth ? ref.watch(wishlistControllerProvider) : null;
    final isWishlisted =
        wishlistState?.resolve(ad.id, fallback: ad.isWishlisted) ?? false;
    final isPending = wishlistState?.pending.contains(ad.id) ?? false;

    Future<void> toggleWishlist() async {
      final success = await ref
          .read(wishlistControllerProvider.notifier)
          .toggle(ad.id, currentValue: isWishlisted);

      if (!success && context.mounted) {
        ShowSnack(context, context.l10n.wishlist_update_error).error();
      }
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: imageUrl == null || imageUrl.isEmpty
                ? ColoredBox(
                    color: colors.elevated,
                    child: Icon(Icons.image_outlined, color: colors.textMuted),
                  )
                : AppNetworkImage(
                    url: imageUrl,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
          ),
        ),

        /// top row
        Positioned(
          top: 6,
          left: 6,
          right: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (ad.isOfferActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '-${ad.offerPercent.round()}%',
                    style: TextStyle(
                      color: colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(),

              Semantics(
                button: true,
                enabled: !isPending,
                label: isWishlisted
                    ? context.l10n.wishlist_remove
                    : context.l10n.wishlist_add,
                child: Material(
                  color: colors.surface.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isPending
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
                        child: isPending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: isWishlisted
                                    ? colors.primary
                                    : colors.textPrimary,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
