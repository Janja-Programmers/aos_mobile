// features/live/presentation/widgets/live_card.dart

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/bottom_caption_overlay.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/right_metrics_overlay.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/short_thumbnail.dart';
import 'package:flutter/material.dart';

class LiveCard extends StatelessWidget {
  final LiveStream live;
  final VoidCallback onTap;

  const LiveCard({super.key, required this.live, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final caption = live.title.trim();

    final imageUrl =
        _safeFileUrl(live.thumbnail) ?? _safeFileUrl(live.coverImage) ?? '';

    final sellerName = live.hostDisplayName.trim().isNotEmpty
        ? live.hostDisplayName.trim()
        : 'Live';

    final avatarUrl = _safeFileUrl(live.hostAvatar);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border.withValues(alpha: .55)),
          ),
          child: Stack(
            children: [
              ShortThumbnail(imageUrl: imageUrl),

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.black.withValues(alpha: .04),
                          colors.black.withValues(alpha: .08),
                          colors.black.withValues(alpha: .68),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Positioned(top: 8, left: 8, child: _LiveBadge()),

              Positioned(
                right: 7,
                bottom: 12,
                child: RightMetricsOverlay(
                  avatarUrl: avatarUrl,
                  sellerName: sellerName,
                  likeCount: live.likeCount,
                  commentCount: live.commentCount,
                  isLiked: false,
                ),
              ),

              Positioned(
                left: 9,
                right: 48,
                bottom: 10,
                child: BottomCaptionOverlay(
                  caption: caption,
                  sellerName: sellerName,
                ),
              ),
            ],
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

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: colors.white),

          const SizedBox(width: 5),

          Text(
            'LIVE',
            style: context.p.copyWith(
              color: colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }
}
