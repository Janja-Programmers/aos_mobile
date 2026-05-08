import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_session_controller.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/comment_sheet.dart';

class ShortActionsPanel extends ConsumerWidget {
  final Short short;
  final bool isLikePending;
  final Future<void> Function(String shortId) onToggleLike;
  final void Function(String shortId) onCommentAdded;

  const ShortActionsPanel({
    super.key,
    required this.short,
    required this.onToggleLike,
    required this.onCommentAdded,
    this.isLikePending = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final isLiked = short.isLiked;
    final metrics = short.metrics;

    return Column(
      children: [
        _circleButton(icon: Icons.add, onTap: () {}),

        const SizedBox(height: 18),

        _iconWithLabel(
          context,
          icon: Icons.favorite,
          color: isLiked ? colors.primary : colors.white,
          label: _formatCount(metrics.likeCount),
          isDisabled: isLikePending,
          onTap: isLikePending
              ? null
              : () {
                  onToggleLike(short.id.value);
                },
        ),

        const SizedBox(height: 18),

        _iconWithLabel(
          context,
          icon: Icons.comment,
          color: colors.white,
          label: _formatCount(metrics.commentCount),
          onTap: () {
            ref.read(shortSessionControllerProvider.notifier).pause();

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CommentsSheet(
                short: short,
                onCommentAdded: () {
                  onCommentAdded(short.id.value);
                },
              ),
            ).whenComplete(() {
              ref.read(shortSessionControllerProvider.notifier).resume();
            });
          },
        ),

        const SizedBox(height: 18),

        _iconWithLabel(
          context,
          icon: Icons.share,
          label: 'Share',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _circleButton({required IconData icon, VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black54,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
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
    bool isDisabled = false,
  }) {
    final colors = context.appColors;

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(icon, color: color ?? colors.white, size: 32),
            ),
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
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}
