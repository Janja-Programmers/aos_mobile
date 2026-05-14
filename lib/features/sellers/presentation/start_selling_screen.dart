import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/controllers/seller_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/seller_action_tiles.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';

class StartSellingScreen extends ConsumerWidget {
  const StartSellingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final auth = ref.watch(authControllerProvider);
    final isAuthenticated = auth is AuthAuthenticated;

    final statusAsync = isAuthenticated
        ? ref.watch(sellerStatusProvider)
        : null;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        centerTitle: false,
        title: Text("Start Selling", style: context.h5),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => context.pushNamed(AppRoutes.nMyAds),
              icon: Icon(Icons.list, color: colors.black),
              label: Text("My Listings", style: context.h6),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ActionTile(
              leading: Icon(Icons.camera_alt, color: colors.textPrimary),
              iconBackgroundColor: colors.border,
              title: "Post an Ad",
              subtitle:
                  "Sell your products or service by creating a listing that buyers can find and contact you about.",
              onTap: () => context.pushNamed(AppRoutes.nCreateAd),
            ),
            const SizedBox(height: 12),

            if (statusAsync != null)
              ...statusAsync.when(
                data: (status) {
                  return [
                    if (status.isSeller) ...[
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
                    ],

                    if (status.isVerified) ...[
                      ActionTile(
                        leading: Icon(Icons.tv, color: colors.primary),
                        iconBackgroundColor: colors.primary.withOpacity(.15),
                        title: "Go Live",
                        subtitle:
                            "Stream live, engage your audience and sell instantly",
                        onTap: () => LiveNavigation.toGoLiveScreen(context),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ];
                },
                loading: () => <Widget>[const SizedBox.shrink()],
                error: (_, _) => <Widget>[const SizedBox.shrink()],
              ),
          ],
        ),
      ),
    );
  }
}
