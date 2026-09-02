import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/short_sound_dialog.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:flutter/material.dart';

class ShortBottomInfo extends StatelessWidget {
  const ShortBottomInfo({super.key, required this.short});

  final Short short;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final displayName = _resolveDisplayName();
    final captionText = _composeCaption();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  displayName,
                  style: context.p.copyWith(
                    color: colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (short.isCreatorVerified) ...<Widget>[
                const SizedBox(width: 4),
                Semantics(
                  label: 'Verified creator',
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF29A9FF),
                    size: 15,
                  ),
                ),
              ],
            ],
          ),
          if (captionText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              captionText,
              style: context.p.copyWith(color: colors.white, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (short.isAudioMixing) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              'Updating audio...',
              style: context.small.copyWith(
                color: colors.white.withValues(alpha: .72),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: 'Open Short sound details',
            child: InkWell(
              onTap: () => showShortSoundDialog(context, short: short),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.music_note_rounded,
                      color: colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _soundLabel(),
                        style: context.small.copyWith(
                          color: colors.white.withValues(alpha: .92),
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveDisplayName() {
    final displayName = short.creator.displayName.trim();
    if (displayName.isNotEmpty) return displayName;

    final fallbackUser = short.creator.user.trim();
    if (fallbackUser.isNotEmpty) return fallbackUser;

    return 'User';
  }

  String _soundLabel() {
    final sound = short.sound;
    if (sound == null || sound.isOriginal || sound.isOriginalAudio) {
      final creator = _resolveDisplayName();
      return creator == 'User' ? 'Original sound' : 'Original sound · $creator';
    }

    final title = sound.title.trim().isEmpty ? 'Sound' : sound.title.trim();
    final artist = sound.artist.trim();
    if (artist.isEmpty) return title;
    return '$title · $artist';
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
