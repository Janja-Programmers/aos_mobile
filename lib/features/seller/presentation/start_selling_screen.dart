import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/seller/presentation/widgets/seller_action_tiles.dart';
import 'package:africaonlinestores/features/shorts/navigation/shorts_routes.dart';

// 👇 ADD THIS
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';

class StartSellingScreen extends ConsumerWidget {
  const StartSellingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

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
              title: "Post an Item",
              subtitle: "Create a standard photo listing.",
              onTap: () => context.pushNamed(AppRoutes.nCreateAd),
            ),
            const SizedBox(height: 12),

            ActionTile(
              leading: Icon(Icons.videocam, color: colors.primary),
              iconBackgroundColor: colors.primary.withOpacity(.15),
              title: "Post a Short Video",
              subtitle: "Record a 60s video of your product.",
              onTap: () => ShortsNavigation.toCreateShort(context),
            ),
            const SizedBox(height: 12),

            // 🔥 FINAL WIRING
            ActionTile(
              leading: Icon(Icons.wifi_tethering, color: colors.primary),
              iconBackgroundColor: colors.primary.withOpacity(.15),
              title: "Join Live",
              subtitle: "Stream live to your followers",
              onTap: () {
                ref
                    .read(liveManagerProvider.notifier)
                    .joinLive(liveId: "LIVE-2026-00004");
              },
            ),

            const SizedBox(height: 12),

            // 🔥 FINAL WIRING
            ActionTile(
              leading: Icon(Icons.wifi_tethering, color: colors.primary),
              iconBackgroundColor: colors.primary.withOpacity(.15),
              title: "Go Live",
              subtitle: "Stream live to your followers",
              onTap: () {
                ref
                    .read(liveManagerProvider.notifier)
                    .startLive(title: "Live with you 🔴");
              },
            ),

            const SizedBox(height: 12),

            ActionTile(
              leading: Icon(Icons.feed_outlined, color: colors.primary),
              iconBackgroundColor: colors.primary.withOpacity(.15),
              title: "Feeds for You",
              subtitle: "View some shorts",
              onTap: () => ShortsNavigation.toShorts(context),
            ),
          ],
        ),
      ),
    );
  }
}
