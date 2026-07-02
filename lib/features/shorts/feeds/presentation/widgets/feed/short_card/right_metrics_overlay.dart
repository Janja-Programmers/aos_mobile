import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/mini_metric.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/short_avator.dart';
import 'package:flutter/material.dart';

class RightMetricsOverlay extends StatelessWidget {
  final String? avatarUrl;
  final String sellerName;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const RightMetricsOverlay({
    super.key,
    required this.avatarUrl,
    required this.sellerName,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    const shadow = [
      Shadow(blurRadius: 8, offset: Offset(0, 1), color: Colors.black54),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShortAvatar(
          avatarUrl: avatarUrl,
          name: sellerName,
          size: 32,
          borderColor: colors.white.withValues(alpha: .9),
          borderWidth: 1.4,
        ),

        const SizedBox(height: 12),

        MiniMetric(
          icon: Icons.favorite_rounded,
          value: _formatCount(likeCount),
          iconColor: isLiked ? colors.primary : colors.white,
          textColor: colors.white,
          direction: Axis.vertical,
          iconSize: 22,
          spacing: 4,
          fontWeight: FontWeight.w800,
          shadows: shadow,
        ),

        const SizedBox(height: 12),

        MiniMetric(
          icon: Icons.mode_comment_rounded,
          value: _formatCount(commentCount),
          iconColor: colors.white,
          textColor: colors.white,
          direction: Axis.vertical,
          iconSize: 22,
          spacing: 4,
          fontWeight: FontWeight.w800,
          shadows: shadow,
        ),
      ],
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
