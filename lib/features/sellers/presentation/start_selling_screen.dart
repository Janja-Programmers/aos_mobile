import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/seller_action_tiles.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/verifications/controllers/seller_status_provider.dart';

class StartSellingScreen extends ConsumerWidget {
  const StartSellingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final sellerStatusAsync = ref.watch(sellerStatusProvider);

    final canPostAd = sellerStatusAsync.maybeWhen(
      data: (status) => !status.isSuspended,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (canPostAd) ...[
                  ActionTile(
                    leading: Icon(Icons.camera_alt, color: colors.textPrimary),
                    iconBackgroundColor: colors.border,
                    title: "Post an Ad",
                    subtitle:
                        "Sell your products or service by creating a listing that buyers can find and contact you about.",
                    onTap: () => context.pushNamed(AppRoutes.nCreateAd),
                  ),
                  const SizedBox(height: 12),
                ],

                ActionTile(
                  leading: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: colors.primary,
                  ),
                  iconBackgroundColor: colors.primary.withOpacity(.15),
                  title: "Create a Short Video",
                  subtitle:
                      "Show your products in short videos and reach more people.",
                  onTap: () => ShortsNavigation.toPostShort(context),
                ),
                const SizedBox(height: 12),

                ActionTile(
                  leading: Icon(Icons.tv, color: colors.primary),
                  iconBackgroundColor: colors.primary.withOpacity(.15),
                  title: "Go Live",
                  subtitle:
                      "Stream live, engage your audience and sell instantly",
                  onTap: () => LiveNavigation.toGoLiveScreen(context),
                ),
                const SizedBox(height: 12),

                ActionTile(
                  leading: Icon(Icons.place_outlined, color: colors.primary),
                  iconBackgroundColor: colors.primary.withOpacity(.15),
                  title: "Store Location",
                  subtitle:
                      "Save your shop or pickup point so buyers can find you on the map.",
                  onTap: () => SellerNavigation.toSellerLocation(context),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
