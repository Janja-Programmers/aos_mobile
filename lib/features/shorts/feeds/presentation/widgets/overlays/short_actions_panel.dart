import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_interaction_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_session_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/selectors/short_selectors.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/comment_sheet.dart';

/// ─────────────────────────────────────────────
/// SHORT ACTIONS PANEL
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// → Display interaction buttons
/// → Dispatch interaction intents
///

class ShortActionsPanel extends ConsumerWidget {
  final Short short;

  const ShortActionsPanel({super.key, required this.short});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final interaction = ref.watch(shortInteractionControllerProvider);

    final interactionController = ref.read(
      shortInteractionControllerProvider.notifier,
    );

    final selectors = const ShortsSelectors();

    final isLiked = selectors.isLiked(interaction, short.id.value);

    final metrics = short.metrics;

    return Column(
      children: [
        /// FOLLOW / ADD BUTTON
        _circleButton(icon: Icons.add, onTap: () {}),

        const SizedBox(height: 18),

        /// LIKE
        _iconWithLabel(
          context,
          icon: Icons.favorite,
          color: isLiked ? colors.primary : colors.white,
          label: _formatCount(metrics.likeCount),
          onTap: () {
            interactionController.toggleLike(short.id.value);
          },
        ),

        const SizedBox(height: 18),

        /// COMMENT
        _iconWithLabel(
          context,
          icon: Icons.comment,
          color: colors.white,
          label: _formatCount(metrics.commentCount),
          onTap: () {
            /// Pause playback before opening sheet

            ref.read(shortSessionControllerProvider.notifier).pause();

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: colors.surface,
              builder: (_) => CommentsSheet(short: short),
            ).whenComplete(() {
              /// Resume playback

              ref.read(shortSessionControllerProvider.notifier).resume();
            });
          },
        ),

        const SizedBox(height: 18),

        /// SHARE
        _iconWithLabel(
          context,
          icon: Icons.share,
          label: "Share",
          onTap: () {},
        ),
      ],
    );
  }

  // ───────────── UI HELPERS ─────────────

  Widget _circleButton({required IconData icon, VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black54,
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _iconWithLabel(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    final colors = context.appColors;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: color ?? colors.white, size: 32),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ───────────── FORMATTER ─────────────

  String _formatCount(int value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    }

    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }

    return value.toString();
  }
}
