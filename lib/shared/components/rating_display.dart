import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;

  final double starSize;
  final double textSize;
  final bool showText;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 12,
    this.textSize = 10,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildStars(colors),

        if (showText) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$rating (${humanizeCount(reviewCount)} Reviews)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.pMuted.copyWith(fontSize: textSize),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildStars(AppColorTokens colors) {
    const totalStars = 5;

    if (rating == 0) {
      return List.generate(
        totalStars,
        (_) => Icon(Icons.star_border, size: starSize, color: colors.textMuted),
      );
    }

    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;

    return List.generate(totalStars, (index) {
      if (index < fullStars) {
        return Icon(Icons.star, size: starSize, color: colors.amber);
      } else if (index == fullStars && hasHalfStar) {
        return Icon(Icons.star_half, size: starSize, color: colors.amber);
      } else {
        return Icon(Icons.star_border, size: starSize, color: colors.textMuted);
      }
    });
  }
}
