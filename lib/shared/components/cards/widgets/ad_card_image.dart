import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';

class AdCardImage extends ConsumerWidget {
  const AdCardImage({super.key, required this.ad, required this.height});

  final AOSAdListItem ad;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final imageUrl = buildFileUrl(ad.primaryImage);

    final isAuth = ref.watch(isAuthenticatedProvider);

    Set<String> ids = const {};

    if (isAuth) {
      final wishlist = ref.watch(wishlistControllerProvider).value;
      ids = wishlist?.ids ?? {};
    }

    final isWishlisted = ids.contains(ad.id);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: imageUrl == null || imageUrl.isEmpty
                ? Container(
                    color: colors.elevated,
                    child: Icon(Icons.image_outlined, color: colors.textMuted),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
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
                    "-${ad.offerPercent.round()}%",
                    style: TextStyle(
                      color: colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(),

              GestureDetector(
                onTap: () {
                  AppNavigation.requireAuth(
                    context,
                    ref,
                    onAuthenticated: () {
                      ref
                          .read(wishlistControllerProvider.notifier)
                          .toggle(ad.id);
                    },
                  );
                },
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: colors.surface.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isWishlisted ? colors.primary : colors.textPrimary,
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
