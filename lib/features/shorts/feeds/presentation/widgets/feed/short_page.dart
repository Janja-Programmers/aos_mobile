import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_feed_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/playback/playback_authority.dart';

/// Overlays
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/video/short_video_view.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_bottom_info.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/shop_now_card.dart';

class ShortPage extends ConsumerWidget {
  final int index;

  const ShortPage({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(shortsFeedControllerProvider);

    if (index >= feedState.shorts.length) {
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    }

    final short = feedState.shorts[index];

    appLogger.i("🟠 ShortPage.render | index=$index");

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// ─────────────────────────────
          /// LAYER 1 — VIDEO (PURE RENDER)
          /// ─────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(playbackAuthorityProvider).togglePlayPause(index);
              },
              child: ShortVideoView(index: index),
            ),
          ),

          /// ─────────────────────────────
          /// LAYER 3 — BOTTOM INFO (READ-ONLY UI)
          /// ─────────────────────────────
          Positioned(
            left: 16,
            right: 80,
            bottom: 100,
            child: ShortBottomInfo(short: short),
          ),

          /// ─────────────────────────────
          /// LAYER 4 — ACTIONS (USER INTENT LAYER)
          /// ─────────────────────────────
          Positioned(
            right: 12,
            bottom: 24,
            child: ShortActionsPanel(
              short: short,
              index: index,

              /// IMPORTANT:
              /// These buttons should ONLY call:
              /// - repositories
              /// - action controllers
              /// NOT playback system
            ),
          ),

          /// ─────────────────────────────
          /// LAYER 5 — CONDITIONAL AD CARD
          /// ─────────────────────────────
          if (short.ad != null)
            Positioned(
              left: 16,
              right: 80,
              bottom: 24,
              child: ShopNowCard(
                short: short,
                onTap: () => AdNavigation.toDetail(context, short.ad!.id),
              ),
            ),
        ],
      ),
    );
  }
}
