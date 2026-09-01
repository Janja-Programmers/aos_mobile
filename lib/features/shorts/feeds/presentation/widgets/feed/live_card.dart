import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_card_formatters.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_l10n.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card/short_thumbnail.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
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
    final l10n = context.l10n;
    final title = live.title.trim().isEmpty
        ? l10n.feedLiveNow
        : live.title.trim();
    final hostName = live.host.displayName.trim().isNotEmpty
        ? live.host.displayName.trim()
        : live.hostDisplayName.trim().isNotEmpty
        ? live.hostDisplayName.trim()
        : l10n.feedLive;
    final imageUrl =
        _safeFileUrl(live.thumbnail) ?? _safeFileUrl(live.coverImage) ?? '';
    final borderRadius = fullScreen
        ? BorderRadius.zero
        : BorderRadius.circular(18);

    return Semantics(
      button: true,
      label: l10n.feedLiveCardSemantics(hostName, title, live.viewerCount),
      child: Material(
        color: colors.black,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: fullScreen
                  ? null
                  : Border.all(color: colors.border.withValues(alpha: .55)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isActive && remoteVideoTrack != null)
                  LiveVideoStage(track: remoteVideoTrack, emptyLabel: '')
                else
                  ShortThumbnail(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    fallbackBackgroundColor: colors.black,
                    fallbackIcon: Icons.podcasts_rounded,
                  ),
                if (isActive && remoteVideoTrack == null)
                  Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.white,
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
                            colors.black.withValues(alpha: .03),
                            colors.black.withValues(alpha: .05),
                            colors.black.withValues(alpha: .80),
                          ],
                          stops: const [0, .52, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                const PositionedDirectional(
                  top: 10,
                  start: 10,
                  child: _LiveBadge(),
                ),
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: _ViewerBadge(count: live.viewerCount),
                ),
                PositionedDirectional(
                  start: 11,
                  end: 11,
                  bottom: 11,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.p.copyWith(
                          color: colors.white,
                          fontSize: 16,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.small.copyWith(
                          color: colors.white.withValues(alpha: .78),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          context.l10n.feedLiveBadge,
          style: TextStyle(
            color: colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: .2,
          ),
        ),
      ),
    );
  }
}

class _ViewerBadge extends StatelessWidget {
  final int count;

  const _ViewerBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final compact = MediaQuery.textScalerOf(context).scale(1) > 1.5;

    return Semantics(
      label: context.l10n.feedViewersSemantics(count),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.black.withValues(alpha: .58),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_outlined, size: 13, color: colors.white),
              if (!compact) ...[
                const SizedBox(width: 4),
                Text(
                  formatFeedCount(count),
                  style: TextStyle(
                    color: colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
