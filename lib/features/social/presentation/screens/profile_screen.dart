import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/account/presentation/widgets/profile_edit_sheet.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';

import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';

class ProfileScreen extends ConsumerWidget {
  final String? user;

  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final currentUser = auth.user;
    final colors = context.appColors;

    final isOwnProfile =
        user == null || user!.trim().isEmpty || user == currentUser.email;

    final displayName = isOwnProfile ? currentUser.fullName : user!;
    final username = _usernameFromEmail(
      isOwnProfile ? currentUser.email : user!,
    );

    final imageUrl = currentUser.userImage.isNotEmpty
        ? '${AppConfig.normalizedBaseUrl}${currentUser.userImage}'
        : null;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
        centerTitle: false,
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: notifications/settings route.
            },
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: share profile.
            },
            icon: Icon(Icons.near_me_outlined, color: colors.textPrimary),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(
              displayName: displayName,
              username: username,
              imageUrl: imageUrl,
              bio: isOwnProfile
                  ? (currentUser.bio?.trim().isNotEmpty == true
                        ? currentUser.bio!.trim()
                        : 'Software Engineer')
                  : 'Software Engineer',
              isOwnProfile: isOwnProfile,
              followingCount: '571',
              followersCount: '1,004',
              likesCount: '6,078',
              onFollowingTap: () {
                SocialNavigation.toSocialConnectionsScreen(
                  context,
                  tab: SocialConnectionsTab.following,
                  title: displayName,
                );
              },
              onFollowersTap: () {
                SocialNavigation.toSocialConnectionsScreen(
                  context,
                  tab: SocialConnectionsTab.followers,
                  title: displayName,
                );
              },
              onLikesTap: () {
                // TODO: likes screen when ready.
              },
              onEditTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const ProfileEditSheet(),
                );
              },
              onMessageTap: () {
                // TODO: start/open chat with this user.
              },
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _ProfileTabsHeaderDelegate(
              child: const _ProfileTabs(),
              backgroundColor: colors.surface,
            ),
          ),

          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _ProfileGridItem(index: index);
            }, childCount: 18),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1.5,
              crossAxisSpacing: 1.5,
              childAspectRatio: 0.72,
            ),
          ),
        ],
      ),
    );
  }

  static String _usernameFromEmail(String value) {
    final clean = value.trim();

    if (clean.contains('@')) {
      return clean.split('@').first;
    }

    return clean;
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String username;
  final String? imageUrl;
  final String bio;
  final bool isOwnProfile;

  final String followingCount;
  final String followersCount;
  final String likesCount;

  final VoidCallback onFollowingTap;
  final VoidCallback onFollowersTap;
  final VoidCallback onLikesTap;
  final VoidCallback onEditTap;
  final VoidCallback onMessageTap;

  const _ProfileHeader({
    required this.displayName,
    required this.username,
    required this.imageUrl,
    required this.bio,
    required this.isOwnProfile,
    required this.followingCount,
    required this.followersCount,
    required this.likesCount,
    required this.onFollowingTap,
    required this.onFollowersTap,
    required this.onLikesTap,
    required this.onEditTap,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        const SizedBox(height: 4),

        CircleAvatar(
          radius: 42,
          backgroundColor: colors.border,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Icon(Icons.person_rounded, size: 42, color: colors.textMuted)
              : null,
        ),

        const SizedBox(height: 12),

        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.h5.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          '@$username',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.pMuted.copyWith(fontSize: 13, height: 1.1),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProfileStat(
              value: followingCount,
              label: 'Following',
              onTap: onFollowingTap,
            ),
            const SizedBox(width: 34),
            _ProfileStat(
              value: followersCount,
              label: 'Followers',
              onTap: onFollowersTap,
            ),
            const SizedBox(width: 34),
            _ProfileStat(value: likesCount, label: 'Likes', onTap: onLikesTap),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MainProfileActionButton(
              label: isOwnProfile ? 'Edit profile' : 'Message',
              icon: isOwnProfile ? Icons.edit_outlined : Icons.send_rounded,
              onTap: isOwnProfile ? onEditTap : onMessageTap,
            ),
            const SizedBox(width: 8),
            _RoundProfileActionButton(
              icon: Icons.person_add_alt_1_rounded,
              onTap: () {
                // TODO: follow/friend action.
              },
            ),
            const SizedBox(width: 8),
            _RoundProfileActionButton(
              icon: Icons.arrow_drop_down_rounded,
              onTap: () {
                // TODO: more profile actions.
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            bio,
            textAlign: TextAlign.center,
            style: context.p.copyWith(color: colors.textPrimary, height: 1.25),
          ),
        ),

        const SizedBox(height: 14),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.onTap,
  });

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

  const _MainProfileActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.textPrimary, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.p.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundProfileActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundProfileActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.elevated,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colors.textPrimary, size: 22),
      ),
    );
  }
}

class _ProfileTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  const _ProfileTabsHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(covariant _ProfileTabsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _TabIcon(
                  icon: Icons.grid_view_rounded,
                  isSelected: true,
                  color: colors.textPrimary,
                ),
              ),
              Expanded(
                child: _TabIcon(
                  icon: Icons.repeat_rounded,
                  isSelected: false,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: colors.border),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color color;

  const _TabIcon({
    required this.icon,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: isSelected ? 28 : 0,
          height: 2,
          decoration: BoxDecoration(
            color: isSelected ? colors.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _ProfileGridItem extends StatelessWidget {
  final int index;

  const _ProfileGridItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final isPinned = index == 0;
    final isMulti = index == 1 || index == 5;
    final viewCount = _viewCount(index);

    return Container(
      color: colors.border,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _MockContentThumbnail(index: index),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.black.withOpacity(0.02),
                    colors.black.withOpacity(0.32),
                  ],
                ),
              ),
            ),
          ),

          if (isPinned)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'Pinned',
                  style: context.p.copyWith(
                    color: colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),

          if (isMulti)
            Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.copy_rounded, color: colors.white, size: 16),
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
                        color: colors.black.withOpacity(0.55),
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
    );
  }

  String _viewCount(int index) {
    final values = [
      '12.9K',
      '310',
      '555',
      '1,388',
      '793',
      '1,218',
      '442',
      '927',
      '2,004',
    ];

    return values[index % values.length];
  }
}

class _MockContentThumbnail extends StatelessWidget {
  final int index;

  const _MockContentThumbnail({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final palette = [
      Colors.red.shade300,
      Colors.black87,
      Colors.green.shade300,
      Colors.blueGrey.shade300,
      Colors.indigo.shade700,
      Colors.pink.shade300,
      Colors.purple.shade200,
      Colors.orange.shade300,
      Colors.lightBlue.shade300,
    ];

    return Container(
      color: palette[index % palette.length],
      child: Center(
        child: Icon(
          index.isEven
              ? Icons.play_circle_outline_rounded
              : Icons.image_outlined,
          color: colors.white.withOpacity(0.72),
          size: 34,
        ),
      ),
    );
  }
}
