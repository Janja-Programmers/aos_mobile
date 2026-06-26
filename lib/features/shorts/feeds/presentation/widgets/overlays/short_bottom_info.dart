import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

/// ─────────────────────────────────────────────
/// SHORT BOTTOM INFO
/// ─────────────────────────────────────────────

class ShortBottomInfo extends StatelessWidget {
  final Short short;

  const ShortBottomInfo({super.key, required this.short});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final displayName = _resolveDisplayName();
    final captionText = _composeCaption();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ─────────────────────────────
          /// CREATOR DISPLAY NAME
          /// ─────────────────────────────
          Text(
            displayName,
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

          if (short.hasSound) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note_rounded, color: colors.white, size: 15),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _soundLabel(),
                    style: context.small.copyWith(
                      color: colors.white.withOpacity(.92),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (short.isAudioMixing) ...[
            const SizedBox(height: 6),
            Text(
              'Updating audio...',
              style: context.small.copyWith(
                color: colors.white.withOpacity(.72),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  String _resolveDisplayName() {
    final displayName = short.creator.displayName.trim();

    if (displayName.isNotEmpty) {
      return displayName;
    }

    final fallbackUser = short.creator.user.trim();

    if (fallbackUser.isNotEmpty) {
      return fallbackUser;
    }

    return 'User';
  }

  String _soundLabel() {
    final sound = short.sound;
    if (sound == null) return '';

    final artist = sound.artist.trim();
    if (artist.isEmpty) return sound.title;
    return '${sound.title} • $artist';
  }

  String _composeCaption() {
    final caption = short.caption.value.trim();

    final hashtags = short.hashtags
        .map((tag) {
          final normalized = tag.trim();
          if (normalized.isEmpty) return '';
          return normalized.startsWith('#') ? normalized : '#$normalized';
        })
        .where((tag) => tag.isNotEmpty)
        .join(' ');

    if (caption.isEmpty) return hashtags;

    if (hashtags.isEmpty) return caption;

    return '$caption $hashtags';
  }
}
