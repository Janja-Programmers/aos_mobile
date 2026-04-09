import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
// import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/domain/short.dart';

class ShortBottomInfo extends StatelessWidget {
  final Short short;

  const ShortBottomInfo({super.key, required this.short});

  @override
  Widget build(BuildContext context) {
    // final colors = context.appColors;

    final caption = short.caption.value;
    final hashtags = short.hashtags.join(" ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "@${short.ownerId.isNotEmpty ? short.ownerId : 'user'}",
          style: context.p.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        if (caption.isNotEmpty || hashtags.isNotEmpty)
          Text(
            _buildCaption(caption, hashtags),
            style: context.p.copyWith(height: 1.3),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  // ───────────── HELPER ─────────────

  String _buildCaption(String caption, String hashtags) {
    if (caption.isEmpty) return hashtags;
    if (hashtags.isEmpty) return caption;

    return "$caption $hashtags";
  }
}
