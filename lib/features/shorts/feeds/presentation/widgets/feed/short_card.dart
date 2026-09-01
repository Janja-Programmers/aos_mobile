import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/feed_avatar_image.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_card_formatters.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_l10n.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/short_thumbnail.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class ShortCard extends StatelessWidget {
  final Short short;
  final VoidCallback onTap;

  const ShortCard({super.key, required this.short, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final caption = short.caption.toString().trim();
    final imageUrl = _safeFileUrl(short.thumbnailUrl) ?? '';
    final sellerName = short.sellerShopName.trim().isNotEmpty
        ? short.sellerShopName.trim()
        : l10n.feedCreator;
    final avatarUrl = _safeFileUrl(short.sellerAvatar);
    final duration = formatFeedDuration(short.durationSeconds);

    return Semantics(
      button: true,
      label: l10n.feedShortCardSemantics(sellerName, caption),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border.withValues(alpha: .65)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: .80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ShortThumbnail(imageUrl: imageUrl, fit: BoxFit.cover),
                      PositionedDirectional(
                        top: 8,
                        start: 8,
                        end: 8,
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: _ShortStateBadges(
                            short: short,
                            duration: duration,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (caption.isNotEmpty)
                        Text(
                          caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.p.copyWith(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      if (caption.isNotEmpty) const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox.square(
                            dimension: 27,
                            child: ClipOval(
                              child: FeedAvatarImage(
                                avatar: avatarUrl,
                                fallbackText: sellerName,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              sellerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.small.copyWith(
                                color: colors.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Semantics(
                            label: l10n.feedLikesSemantics(
                              short.metrics.likeCount,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatFeedCount(short.metrics.likeCount),
                                  style: context.small.copyWith(
                                    color: colors.textMuted,
                                    fontSize: 10.5,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.thumb_up_alt_outlined,
                                  size: 13,
                                  color: colors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _safeFileUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final url = buildFileUrl(value);
    if (url == null || url.trim().isEmpty) return null;
    return url;
  }
}

class _ShortStateBadges extends StatelessWidget {
  final Short short;
  final String duration;

  const _ShortStateBadges({required this.short, required this.duration});

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(context, short);
    final audience = short.isPrivateAudience
        ? _audienceLabel(context, short.audience)
        : null;

    final contentModeBadge = _ContentModeBadge.fromShort(short);

    final hasTopBadges = duration.isNotEmpty || contentModeBadge != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTopBadges)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (duration.isNotEmpty) _DurationBadge(duration: duration),

              const Spacer(),

              ?contentModeBadge,
            ],
          ),

        if (status != null) ...[
          if (hasTopBadges) const SizedBox(height: 5),
          _StatusBadge(label: status),
        ],

        if (audience != null) ...[
          if (hasTopBadges || status != null) const SizedBox(height: 5),
          _StatusBadge(label: audience),
        ],
      ],
    );
  }

  String? _statusLabel(BuildContext context, Short short) {
    final l10n = context.l10n;
    if (short.isProcessing) return l10n.feedProcessing;
    if (short.canRetry) return l10n.feedFailed;
    if (short.isHidden) return l10n.feedHidden;
    if (short.isDeleted) return l10n.feedDeleted;
    return null;
  }

  String _audienceLabel(BuildContext context, String audience) {
    final l10n = context.l10n;
    return switch (audience) {
      'followers' => l10n.feedFollowers,
      'friends' => l10n.feedFriends,
      'only_me' => l10n.feedOnlyMe,
      _ => l10n.feedPrivate,
    };
  }
}

class _DurationBadge extends StatelessWidget {
  final String duration;

  const _DurationBadge({required this.duration});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: .76),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, size: 12, color: colors.white),
            const SizedBox(width: 2),
            Text(
              duration,
              style: TextStyle(
                color: colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentModeBadge extends StatelessWidget {
  const _ContentModeBadge({required this.mode});

  final String mode;

  static _ContentModeBadge? fromShort(Short short) {
    final mode = short.contentMode.trim().toLowerCase();
    if (mode == ShortContentModes.shop ||
        mode == ShortContentModes.geo ||
        mode == ShortContentModes.vibes ||
        mode == ShortContentModes.learn) {
      return _ContentModeBadge(mode: mode);
    }

    // Preserve the existing Shop affordance when an older payload has an ad
    // association but omits its content mode.
    if (short.ad != null) {
      return const _ContentModeBadge(mode: ShortContentModes.shop);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final config = switch (mode) {
      ShortContentModes.geo => (
        label: context.l10n.feedGeoBadge,
        icon: Icons.public_outlined,
        color: Colors.green,
      ),
      ShortContentModes.vibes => (
        label: context.l10n.feedVibesBadge,
        icon: Icons.emoji_events_outlined,
        color: Colors.purple,
      ),
      ShortContentModes.learn => (
        label: context.l10n.feedLearnBadge,
        icon: Icons.school_outlined,
        color: Colors.blue,
      ),
      _ => (
        label: context.l10n.feedShopBadge,
        icon: Icons.shopping_bag_outlined,
        color: colors.primary,
      ),
    };

    return Semantics(
      label: config.label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: config.color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(config.icon, size: 11, color: colors.white),
              const SizedBox(width: 3),
              Text(
                config.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: .66),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.white.withValues(alpha: .24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
