import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

/// ─────────────────────────────────────────────
/// SHORT BOTTOM INFO
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// → Render creator + caption metadata
/// → No logic
/// → No state mutation
///

class ShortBottomInfo extends StatelessWidget {
  final Short short;

  const ShortBottomInfo({super.key, required this.short});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final username = _resolveUsername();
    final captionText = _composeCaption();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ─────────────────────────────
          /// USERNAME
          /// ─────────────────────────────
          Text(
            "@$username",
            style: context.p.copyWith(
              color: colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          /// ─────────────────────────────
          /// CAPTION
          /// ─────────────────────────────
          if (captionText.isNotEmpty)
            Text(
              captionText,
              style: context.p.copyWith(color: colors.white, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  String _resolveUsername() {
    final ownerId = short.ownerId;

    if (ownerId.isEmpty) {
      return "user";
    }

    return ownerId;
  }

  String _composeCaption() {
    final caption = short.caption.value;

    final hashtags = short.hashtags.isEmpty ? "" : short.hashtags.join(" ");

    if (caption.isEmpty) return hashtags;

    if (hashtags.isEmpty) return caption;

    return "$caption $hashtags";
  }
}
