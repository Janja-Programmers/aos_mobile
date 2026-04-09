import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/domain/short.dart';

import 'package:africaonlinestores/features/shorts/application/widgets/shorts/short_page/short_actions_panel.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/shorts/short_page/short_bottom_info.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/shorts/short_page/short_gradient_overlay.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/shorts/short_page/short_video_view.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/shorts/short_page/shop_now_card.dart';

class ShortPage extends ConsumerWidget {
  final int index;
  final Short short;

  const ShortPage({super.key, required this.index, required this.short});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(shortsControllerProvider);

    final controller = ref.read(shortsControllerProvider.notifier);
    final player = controller.getPlayer(index);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 🎥 VIDEO (no ClipRect here)
        ShortVideoView(
          controller: player,

          onTap: () {
            if (player == null || !player.value.isInitialized) return;

            if (player.value.isPlaying) {
              player.pause();
            } else {
              player.play();
            }
          },
          onDoubleTap: () {
            controller.toggleLike(index);
          },
        ),

        const ShortGradientOverlay(),

        ShortActionsPanel(short: short, index: index),

        Positioned(
          left: 12,
          right: 12,
          bottom: 16,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShortBottomInfo(short: short),

                const SizedBox(height: 16),

                const ShopNowCard(title: "Title", subtitle: "Price 20, 000"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
