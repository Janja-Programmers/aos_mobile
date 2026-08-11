// features/live/presentation/widgets/live_card.dart

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/bottom_caption_overlay.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/right_metrics_overlay.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/short_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class LiveCard extends StatelessWidget {
  final LiveStream live;
  final VoidCallback onTap;
  final bool isActive;
  final bool fullScreen;
  final lk.RemoteVideoTrack? remoteVideoTrack;

  const LiveCard({
    super.key,
    required this.live,
    required this.onTap,
    this.isActive = false,
    this.fullScreen = false,
    this.remoteVideoTrack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final caption = live.title.trim();

    final imageUrl =
        _safeFileUrl(live.thumbnail) ?? _safeFileUrl(live.coverImage) ?? '';

    final sellerName = live.host.displayName.trim().isNotEmpty
        ? live.host.displayName.trim()
        : 'Live';

    final avatarUrl = _safeFileUrl(live.host.avatarUrl);

    final borderRadius = fullScreen
        ? BorderRadius.zero
        : BorderRadius.circular(16);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.black,
            borderRadius: borderRadius,
            border: fullScreen
                ? null
                : Border.all(color: colors.border.withValues(alpha: .55)),
          ),
          child: Stack(
            fit: fullScreen ? StackFit.expand : StackFit.loose,
            children: [
              if (isActive && remoteVideoTrack != null)
                LiveVideoStage(
                  track: remoteVideoTrack,
                  emptyLabel: 'Connecting…',
                )
              else
                ShortThumbnail(imageUrl: imageUrl, fit: BoxFit.cover),
              if (isActive && remoteVideoTrack == null)
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),

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

              const PositionedDirectional(
                top: 8,
                start: 8,
                child: _LiveBadge(),
              ),

              PositionedDirectional(
                end: 7,
                bottom: 12,
                child: RightMetricsOverlay(
                  avatarUrl: avatarUrl,
                  sellerName: sellerName,
                  likeCount: live.reactionCount,
                  commentCount: live.commentCount,
                  isLiked: false,
                ),
              ),

              PositionedDirectional(
                start: 9,
                end: 48,
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
