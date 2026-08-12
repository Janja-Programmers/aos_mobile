import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:flutter/material.dart';

class LiveTopBar extends StatelessWidget {
  const LiveTopBar({
    super.key,
    required this.viewerCount,
    required this.onEnd,
    required this.isHost,
    this.reactionCount = 0,
    this.hostName = '',
    this.hostAvatar,
    this.title = '',
    this.isEnding = false,
    this.showFollow = false,
    this.isFollowInFlight = false,
    this.followLabel = 'Follow',
    this.onFollow,
  });

  final int viewerCount;
  final int reactionCount;
  final VoidCallback onEnd;
  final bool isHost;
  final String hostName;
  final String? hostAvatar;
  final String title;
  final bool isEnding;
  final bool showFollow;
  final bool isFollowInFlight;
  final String followLabel;
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cleanHostName = hostName.trim().isEmpty
        ? 'Live host'
        : hostName.trim();

    return PositionedDirectional(
      top: 0,
      start: 12,
      end: 12,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _liveBadge(context),
                      _blackBox(
                        context,
                        humanizeCount(reactionCount),
                        icon: Icons.favorite_rounded,
                        semanticsLabel: '$reactionCount reactions',
                      ),
                      _blackBox(
                        context,
                        humanizeCount(viewerCount),
                        icon: Icons.remove_red_eye_outlined,
                        semanticsLabel: '$viewerCount viewers',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: isEnding ? null : onEnd,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(64, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(
                    isEnding
                        ? 'Ending…'
                        : isHost
                        ? 'End'
                        : 'Leave',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AppCircularAvatar(
                  name: cleanHostName,
                  imageUrl: hostAvatar,
                  radius: 20,
                  backgroundColor: colors.black.withValues(alpha: .58),
                  textColor: colors.white,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleanHostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.pStrong.copyWith(color: colors.white),
                      ),
                      if (title.trim().isNotEmpty)
                        Text(
                          title.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStylesX(
                            context,
                          ).caption.copyWith(color: Colors.white70),
                        ),
                    ],
                  ),
                ),
                if (showFollow) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('live_follow_host_button'),
                    onPressed: isFollowInFlight ? null : onFollow,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.btnText,
                      disabledBackgroundColor: colors.primary.withValues(
                        alpha: .72,
                      ),
                      disabledForegroundColor: colors.btnText,
                      minimumSize: const Size(72, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: AppTextStylesX(context).button,
                    ),
                    child: Text(
                      isFollowInFlight
                          ? '${_cleanFollowLabel()}…'
                          : _cleanFollowLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStylesX(context).button,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _cleanFollowLabel() {
    final clean = followLabel.trim();
    return clean.isEmpty ? 'Follow' : clean;
  }

  Widget _liveBadge(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      label: 'Live now',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: colors.white),
              const SizedBox(width: 4),
              Text('LIVE', style: context.p.copyWith(color: colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blackBox(
    BuildContext context,
    String text, {
    required IconData icon,
    required String semanticsLabel,
  }) {
    return Semantics(
      label: semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .62),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(text, style: context.p.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
