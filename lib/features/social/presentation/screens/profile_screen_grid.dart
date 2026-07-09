part of 'profile_screen.dart';

class _ProfileGridItem extends StatelessWidget {
  final Short short;
  final List<Short> initialShorts;
  final int initialIndex;

  const _ProfileGridItem({
    required this.short,
    required this.initialShorts,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final thumbnail =
        buildFileUrl(short.thumbnailUrl) ??
        buildFileUrl(short.playbackUrl) ??
        short.thumbnailUrl ??
        short.playbackUrl;
    final viewCount = _formatCompact(short.metrics.viewCount);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ShortsNavigation.toShortDetail(
          context,
          initialShorts: initialShorts,
          initialIndex: initialIndex,
          initialNextCursor: null,
          initialHasMore: false,
        );
      },
      child: ColoredBox(
        color: colors.border,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnail.trim().isNotEmpty)
              Image.network(
                thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _PostFallbackIcon(short: short),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _PostFallbackIcon(short: short);
                },
              )
            else
              _PostFallbackIcon(short: short),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.black.withValues(alpha: 0.02),
                      colors.black.withValues(alpha: 0.32),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 5,
              bottom: 5,
              child: Row(
                children: [
                  Icon(Icons.play_arrow_rounded, color: colors.white, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    viewCount,
                    style: context.p.copyWith(
                      color: colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: colors.black.withValues(alpha: 0.55),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCompact(int value) {
    if (value >= 1000000) {
      final short = value / 1000000;
      return '${short.toStringAsFixed(short >= 10 ? 0 : 1)}M';
    }
    if (value >= 1000) {
      final short = value / 1000;
      return '${short.toStringAsFixed(short >= 10 ? 0 : 1)}K';
    }
    return value.toString();
  }
}

class _PostFallbackIcon extends StatelessWidget {
  final Short short;

  const _PostFallbackIcon({required this.short});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ColoredBox(
      color: colors.elevated,
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: colors.white.withValues(alpha: 0.72),
          size: 34,
        ),
      ),
    );
  }
}

class _ProfileGridSkeleton extends StatelessWidget {
  final int index;

  const _ProfileGridSkeleton({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ColoredBox(
      color: index.isEven ? colors.elevated : colors.border,
      child: Center(
        child: Icon(
          Icons.grid_view_rounded,
          color: colors.textMuted.withValues(alpha: 0.3),
          size: 24,
        ),
      ),
    );
  }
}

class _EmptyProfilePanelView extends StatelessWidget {
  final bool isOwnProfile;
  final _ProfilePanel panel;

  const _EmptyProfilePanelView({
    required this.isOwnProfile,
    required this.panel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final icon = switch (panel) {
      _ProfilePanel.posts => Icons.video_library_outlined,
      _ProfilePanel.reposted => Icons.repeat_rounded,
      _ProfilePanel.privateShorts => Icons.lock_outline_rounded,
    };
    final title = switch (panel) {
      _ProfilePanel.posts =>
        isOwnProfile ? 'No posts yet' : 'No public posts yet',
      _ProfilePanel.reposted => 'No reposted shorts yet',
      _ProfilePanel.privateShorts => isOwnProfile
          ? 'No private shorts yet'
          : 'Private shorts are hidden',
    };
    final message = switch (panel) {
      _ProfilePanel.posts =>
        isOwnProfile
            ? 'Your published shorts will appear here.'
            : 'This user has no visible posts yet.',
      _ProfilePanel.reposted =>
        isOwnProfile
            ? 'Shorts you repost will appear here.'
            : 'Visible reposted shorts will appear here.',
      _ProfilePanel.privateShorts =>
        isOwnProfile
            ? 'Only-me, follower-only, friend-only, and hidden shorts appear here.'
            : 'Only this user can view their private shorts.',
    };

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42, color: colors.textMuted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.pStrong.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: context.pMuted),
        ],
      ),
    );
  }
}
