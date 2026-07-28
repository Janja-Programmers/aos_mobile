part of 'profile_screen.dart';

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onActivityTap;
  final VoidCallback? onMoreTap;

  const _ProfileAppBar({
    required this.title,
    required this.onActivityTap,
    this.onMoreTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: BackButton(color: colors.textPrimary),
      centerTitle: true,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.pStrong.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Activity Center',
          onPressed: onActivityTap,
          icon: Icon(Icons.local_activity_outlined, color: colors.textPrimary),
        ),
        if (onMoreTap != null)
          IconButton(
            tooltip: 'More',
            onPressed: onMoreTap,
            icon: Icon(Icons.more_horiz, color: colors.textPrimary),
          ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String username;
  final String? imageUrl;
  final String bio;
  final bool isVerified;
  final bool isOwnProfile;
  final bool isLive;
  final String? liveId;

  final String followingCount;
  final String followersCount;
  final String likesCount;

  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onSellerStoreTap;
  final VoidCallback? onFollowTap;
  final String followActionLabel;
  final bool isFollowing;
  final bool messageLoading;
  final bool followLoading;

  const _ProfileHeader({
    required this.displayName,
    required this.username,
    required this.imageUrl,
    required this.bio,
    required this.isVerified,
    required this.isOwnProfile,
    required this.isLive,
    required this.liveId,
    required this.followingCount,
    required this.followersCount,
    required this.likesCount,
    required this.onFollowingTap,
    required this.onFollowersTap,
    required this.onAvatarTap,
    required this.onEditTap,
    required this.onMessageTap,
    required this.onSellerStoreTap,
    required this.onFollowTap,
    required this.followActionLabel,
    required this.isFollowing,
    required this.messageLoading,
    required this.followLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAvatarTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 98,
                height: 98,
                padding: EdgeInsets.all(isLive ? 4 : 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isLive
                        ? colors.primary
                        : colors.primary.withValues(alpha: 0.18),
                    width: isLive ? 2.4 : 1.4,
                  ),
                  boxShadow: isLive
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.34),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.18),
                            blurRadius: 34,
                            spreadRadius: 8,
                          ),
                        ]
                      : const [],
                ),
                child: CircleAvatar(
                  backgroundColor: colors.border,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: imageUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: colors.primary,
                        )
                      : null,
                ),
              ),
              if (isOwnProfile && !isLive)
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: colors.white,
                      size: 18,
                    ),
                  ),
                )
              else if (isLive && (liveId?.trim().isNotEmpty ?? false))
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                    child: Text(
                      'LIVE',
                      style: context.small.copyWith(
                        color: colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.h5.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 6),
                const VerifiedBadge(size: 22),
              ],
            ],
          ),
        ),
        if (username.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '@$username',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.pMuted.copyWith(fontSize: 14, height: 1.1),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProfileStat(
              value: followingCount,
              label: 'Following',
              onTap: onFollowingTap,
            ),
            Container(
              width: 1,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 26),
              color: colors.border,
            ),
            _ProfileStat(
              value: followersCount,
              label: 'Followers',
              onTap: onFollowersTap,
            ),
            Container(
              width: 1,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 26),
              color: colors.border,
            ),
            _ProfileStat(value: likesCount, label: 'Likes'),
          ],
        ),
        if (bio.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Text(
              bio,
              textAlign: TextAlign.center,
              style: context.p.copyWith(
                color: colors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: isOwnProfile
              ? _MainProfileActionButton(
                  key: const Key('profile_edit_action'),
                  label: 'Edit profile',
                  icon: Icons.edit_outlined,
                  onTap: onEditTap,
                  expanded: true,
                  outlined: true,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onSellerStoreTap != null) ...[
                      _MainProfileActionButton(
                        label: 'Visit Seller Storefront',
                        icon: Icons.storefront_outlined,
                        onTap: onSellerStoreTap!,
                        expanded: true,
                        outlined: true,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (onMessageTap != null || onFollowTap != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (onMessageTap != null)
                            Expanded(
                              child: _MainProfileActionButton(
                                key: const Key('profile_message_action'),
                                label: 'Message',
                                icon: Icons.send_rounded,
                                onTap: onMessageTap!,
                                expanded: true,
                                loading: messageLoading,
                              ),
                            ),
                          if (onMessageTap != null && onFollowTap != null)
                            const SizedBox(width: 10),
                          if (onFollowTap != null)
                            _FollowProfileActionButton(
                              key: const Key('profile_follow_action'),
                              label: followActionLabel,
                              isFollowing: isFollowing,
                              onTap: onFollowTap,
                              loading: followLoading,
                            ),
                        ],
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _ProfileStat({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          children: [
            Text(
              value,
              style: context.pStrong.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.pMuted.copyWith(fontSize: 12, height: 1.05),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainProfileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool expanded;
  final bool outlined;
  final bool loading;

  const _MainProfileActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.expanded = false,
    this.outlined = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final child = Container(
      height: 48,
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : colors.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outlined ? colors.border : colors.elevated),
      ),
      child: loading
          ? Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.textPrimary,
                ),
              ),
            )
          : Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!outlined) ...[
                  Icon(icon, color: colors.textPrimary, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: context.pStrong.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: expanded ? SizedBox(width: double.infinity, child: child) : child,
    );
  }
}

class _FollowProfileActionButton extends StatelessWidget {
  final String label;
  final bool isFollowing;
  final VoidCallback? onTap;
  final bool loading;

  const _FollowProfileActionButton({
    super.key,
    required this.label,
    required this.isFollowing,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Container(
        height: 44,
        constraints: const BoxConstraints(minWidth: 108),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isFollowing ? colors.elevated : colors.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isFollowing ? colors.textPrimary : colors.white,
                ),
              ),
            ] else ...[
              Icon(
                isFollowing
                    ? Icons.check_rounded
                    : Icons.person_add_alt_1_rounded,
                color: isFollowing ? colors.textPrimary : colors.white,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                label.trim().isNotEmpty ? label.trim() : 'Follow',
                style: context.p.copyWith(
                  color: isFollowing ? colors.textPrimary : colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
