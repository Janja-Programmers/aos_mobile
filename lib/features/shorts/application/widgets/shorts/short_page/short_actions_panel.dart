import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/shorts/short_page/comment_sheet.dart';

class ShortActionsPanel extends ConsumerWidget {
  final String shortId;

  const ShortActionsPanel({super.key, required this.shortId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final state = ref.watch(shortsControllerProvider);
    final controller = ref.read(shortsControllerProvider.notifier);

    // ✅ SAFE: find short by ID
    final short = state.shorts.firstWhere(
      (e) => e.id.value == shortId,
      orElse: () => state.shorts.first, // fallback safety
    );

    final metrics = short.metrics;

    // ✅ CRITICAL: resolve index from ID
    final index = state.shorts.indexWhere((e) => e.id.value == shortId);

    if (index == -1) {
      // 🔒 safety guard (should never happen)
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 12,
      bottom: 140,
      child: Column(
        children: [
          _circleButton(icon: Icons.add),

          const SizedBox(height: 18),

          _iconWithLabel(
            context,
            icon: Icons.favorite,
            color: metrics.likedByMe ? colors.primary : colors.white,
            label: _formatCount(metrics.likeCount),
            onTap: () => controller.toggleLike(shortId),
          ),

          const SizedBox(height: 18),

          _iconWithLabel(
            context,
            icon: Icons.comment,
            color: colors.white,
            label: _formatCount(metrics.commentCount),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: colors.surface,
                builder: (_) => CommentsSheet(short: short),
              );
            },
          ),

          const SizedBox(height: 18),

          _iconWithLabel(
            context,
            icon: Icons.share,
            label: "Share",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ───────────── UI HELPERS ─────────────

  Widget _circleButton({required IconData icon}) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black54,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {},
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
            color: colors.primary,
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
