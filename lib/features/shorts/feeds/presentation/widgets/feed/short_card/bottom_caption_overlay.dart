import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class BottomCaptionOverlay extends StatelessWidget {
  final String caption;
  final String sellerName;

  const BottomCaptionOverlay({
    super.key,
    required this.caption,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (caption.isNotEmpty) ...[
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.small.copyWith(
              color: colors.white.withOpacity(.94),
              fontSize: 11,
              height: 1.18,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(
                  blurRadius: 8,
                  offset: Offset(0, 1),
                  color: Colors.black54,
                ),
              ],
            ),
          ),

          const SizedBox(height: 3),
        ],

        Text(
          sellerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.small.copyWith(
            color: colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                blurRadius: 8,
                offset: Offset(0, 1),
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
