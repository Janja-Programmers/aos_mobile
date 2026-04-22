import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_feed_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/video/short_video_view.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_actions_panel.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_bottom_info.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_gradient_overlay.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/shop_now_card.dart';

/// ─────────────────────────────────────────────
/// SHORT PAGE
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// → Compose video + overlays
///

class ShortPage extends ConsumerWidget {
  final int index;

  const ShortPage({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(shortsFeedControllerProvider);

    appLogger.i("🟠 ShortPage.build | index=$index");

    if (index >= feedState.shorts.length) {
      appLogger.i(
        "❌ ShortPage OUT OF BOUNDS | index=$index | length=${feedState.shorts.length}",
      );
    }

    /// Safety guard
    if (index >= feedState.shorts.length) {
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    }

    final short = feedState.shorts[index];

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// ─────────────────────────────
          /// LAYER 1 — VIDEO
          /// ─────────────────────────────
          ShortVideoView(index: index),

          /// ─────────────────────────────
          /// LAYER 3 — GRADIENT
          /// (always above video)
          /// ─────────────────────────────
          const ShortGradientOverlay(),

          /// ─────────────────────────────
          /// LAYER 3 — BOTTOM INFO
          /// ─────────────────────────────
          Positioned(
            left: 16,
            right: 80,
            bottom: 24,
            child: ShortBottomInfo(short: short),
          ),

          /// ─────────────────────────────
          /// LAYER 2 — ACTION PANEL
          /// ─────────────────────────────
          Positioned(
            right: 12,
            bottom: 24,
            child: ShortActionsPanel(short: short, index: index),
          ),

          /// ─────────────────────────────
          /// LAYER 3 — SHOP CARD
          /// (conditional UI) ?Confirm how
          /// ─────────────────────────────
          Positioned(left: 16, bottom: 140, child: ShopNowCard(short: short)),
        ],
      ),
    );
  }
}
