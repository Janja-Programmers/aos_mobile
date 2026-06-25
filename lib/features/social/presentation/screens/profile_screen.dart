import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/profile_edit_sheet.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/features/social/safety/presentation/widgets/user_safety_sheet.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ProfileScreen extends ConsumerWidget {
  final String? user;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const ProfileScreen({
    super.key,
    this.user,
    this.fallbackDisplayName,
    this.fallbackAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final currentUser = auth.user;
    final targetUser = _cleanUser(user).isNotEmpty
        ? _cleanUser(user)
        : currentUser.email.trim();
    final isOwnProfile = _sameUser(targetUser, currentUser.email);
    final colors = context.appColors;

    final request = _ProfileRequest(
      targetUser: targetUser,
      currentUserEmail: currentUser.email,
      currentDisplayName: currentUser.fullName,
      currentAvatar: currentUser.userImage,
      currentBio: currentUser.bio,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );

    final profileAsync = ref.watch(_profileViewDataProvider(request));

    return profileAsync.when(
      loading: () {
        final fallback = _ProfileViewData.fallback(
          targetUser: targetUser,
          isOwnProfile: isOwnProfile,
          currentDisplayName: currentUser.fullName,
          currentAvatar: currentUser.userImage,
          currentBio: currentUser.bio,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatar: fallbackAvatar,
        );

        return _ProfileScaffold(
          data: fallback,
          isLoading: true,
          onRefresh: () async {
            ref.invalidate(_profileViewDataProvider(request));
            await ref.read(_profileViewDataProvider(request).future);
          },
          onShareTap: () => _shareProfile(fallback),
          onEditTap: () => _showEditSheet(context),
          onMessageTap: () {},
          onFollowTap: null,
        );
      },
      error: (error, _) {
        final fallback = _ProfileViewData.fallback(
          targetUser: targetUser,
          isOwnProfile: isOwnProfile,
          currentDisplayName: currentUser.fullName,
          currentAvatar: currentUser.userImage,
          currentBio: currentUser.bio,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatar: fallbackAvatar,
        );

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: _ProfileAppBar(
            title: fallback.displayName,
            onShareTap: () => _shareProfile(fallback),
            onMoreTap: fallback.isOwnProfile
                ? null
                : () => _showSafetySheet(context, fallback),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_search_rounded,
                    size: 40,
                    color: colors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load profile.',
                    style: context.pStrong.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: context.pMuted,
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(_profileViewDataProvider(request)),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (data) {
        return _ProfileScaffold(
          data: data,
          onRefresh: () async {
            ref.invalidate(_profileViewDataProvider(request));
            await ref.read(_profileViewDataProvider(request).future);
          },
          onShareTap: () => _shareProfile(data),
          onEditTap: () => _showEditSheet(context),
          onMessageTap: () {
            ShowSnack(context, 'Open this chat from messages for now.').info();
          },
          onFollowTap: data.isOwnProfile
              ? null
              : () async {
                  final res = await ref
                      .read(socialRepositoryProvider)
                      .toggleFollow(targetUser: data.user);

                  if (!context.mounted) return;

                  if (res.isLeft) {
                    ShowSnack(
                      context,
                      res.leftOrNull?.message ?? 'Failed to update follow.',
                    ).error();
                    return;
                  }

                  ref.invalidate(_profileViewDataProvider(request));
                },
        );
      },
    );
  }

  static String _cleanUser(String? value) => value?.trim() ?? '';

  static bool _sameUser(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  static void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileEditSheet(),
    );
  }

  static Future<void> _shareProfile(_ProfileViewData data) async {
    final cleanUser = Uri.encodeQueryComponent(data.user.trim());
    final url = '${AppConfig.normalizedBaseUrl}/profile?user=$cleanUser';
    final title = data.displayName.trim().isNotEmpty
        ? data.displayName.trim()
        : 'AOS profile';

    await Share.share('View $title on AOS\n$url', subject: title);
  }

  static void _showSafetySheet(BuildContext context, _ProfileViewData data) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          UserSafetySheet(targetUser: data.user, displayName: data.displayName),
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  final _ProfileViewData data;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback onShareTap;
  final VoidCallback onEditTap;
  final VoidCallback onMessageTap;
  final VoidCallback? onFollowTap;

  const _ProfileScaffold({
    required this.data,
    this.isLoading = false,
    required this.onRefresh,
    required this.onShareTap,
    required this.onEditTap,
    required this.onMessageTap,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _ProfileAppBar(
        title: data.displayName,
        onShareTap: onShareTap,
        onMoreTap: data.isOwnProfile
            ? null
            : () => ProfileScreen._showSafetySheet(context, data),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                displayName: data.displayName,
                username: data.username,
                imageUrl: data.avatarUrl,
                bio: data.bio,
                isOwnProfile: data.isOwnProfile,
                followingCount: _formatCount(data.followingCount),
                followersCount: _formatCount(data.followersCount),
                friendsCount: _formatCount(data.friendsCount),
                onFollowingTap: () {
                  SocialNavigation.toSocialConnectionsScreen(
                    context,
                    tab: SocialConnectionsTab.following,
                    title: data.displayName,
                    user: data.user,
                  );
                },
                onFollowersTap: () {
                  SocialNavigation.toSocialConnectionsScreen(
                    context,
                    tab: SocialConnectionsTab.followers,
                    title: data.displayName,
                    user: data.user,
                  );
                },
                onFriendsTap: () {
                  SocialNavigation.toSocialConnectionsScreen(
                    context,
                    tab: SocialConnectionsTab.friends,
                    title: data.displayName,
                    user: data.user,
                  );
                },
                onEditTap: onEditTap,
                onMessageTap: onMessageTap,
                followActionLabel: data.followActionLabel,
                isFollowing: data.isFollowing,
                onFollowTap: onFollowTap,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileTabsHeaderDelegate(
                child: const _ProfileTabs(),
                backgroundColor: colors.surface,
              ),
            ),
            if (isLoading)
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ProfileGridSkeleton(index: index),
                  childCount: 9,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1.5,
                  crossAxisSpacing: 1.5,
                  childAspectRatio: 0.72,
                ),
              )
            else if (data.posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyPostsView(isOwnProfile: data.isOwnProfile),
              )
            else
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _ProfileGridItem(short: data.posts[index]);
                }, childCount: data.posts.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1.5,
                  crossAxisSpacing: 1.5,
                  childAspectRatio: 0.72,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatCount(int value) {
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

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onShareTap;
  final VoidCallback? onMoreTap;

  const _ProfileAppBar({
    required this.title,
    required this.onShareTap,
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
          tooltip: 'Share profile',
          onPressed: onShareTap,
          icon: Icon(Icons.near_me_outlined, color: colors.textPrimary),
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
  final bool isOwnProfile;

  final String followingCount;
  final String followersCount;
  final String friendsCount;

  final VoidCallback onFollowingTap;
  final VoidCallback onFollowersTap;
  final VoidCallback onFriendsTap;
  final VoidCallback onEditTap;
  final VoidCallback onMessageTap;
  final VoidCallback? onFollowTap;
  final String followActionLabel;
  final bool isFollowing;

  const _ProfileHeader({
    required this.displayName,
    required this.username,
    required this.imageUrl,
    required this.bio,
    required this.isOwnProfile,
    required this.followingCount,
    required this.followersCount,
    required this.friendsCount,
    required this.onFollowingTap,
    required this.onFollowersTap,
    required this.onFriendsTap,
    required this.onEditTap,
    required this.onMessageTap,
    required this.onFollowTap,
    required this.followActionLabel,
    required this.isFollowing,
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
        Row(
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
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
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
            _ProfileStat(
              value: friendsCount,
              label: 'Friends',
              onTap: onFriendsTap,
            ),
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
            if (!isOwnProfile) ...[
              const SizedBox(width: 8),
              _FollowProfileActionButton(
                label: followActionLabel,
                isFollowing: isFollowing,
                onTap: onFollowTap,
              ),
            ],
          ],
        ),
        if (bio.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              bio,
              textAlign: TextAlign.center,
              style: context.p.copyWith(
                color: colors.textPrimary,
                height: 1.25,
              ),
            ),
          ),
        ],
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

class _FollowProfileActionButton extends StatelessWidget {
  final String label;
  final bool isFollowing;
  final VoidCallback? onTap;

  const _FollowProfileActionButton({
    required this.label,
    required this.isFollowing,
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isFollowing ? colors.elevated : colors.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        ),
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
  final Short short;

  const _ProfileGridItem({required this.short});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final thumbnail =
        buildFileUrl(short.thumbnailUrl) ??
        buildFileUrl(short.playbackUrl) ??
        short.thumbnailUrl ??
        short.playbackUrl;
    final viewCount = _formatCompact(short.metrics.viewCount);

    return Container(
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
                    colors.black.withOpacity(0.02),
                    colors.black.withOpacity(0.32),
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

    return Container(
      color: colors.elevated,
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: colors.white.withOpacity(0.72),
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

    return Container(
      color: index.isEven ? colors.elevated : colors.border,
      child: Center(
        child: Icon(
          Icons.grid_view_rounded,
          color: colors.textMuted.withOpacity(0.3),
          size: 24,
        ),
      ),
    );
  }
}

class _EmptyPostsView extends StatelessWidget {
  final bool isOwnProfile;

  const _EmptyPostsView({required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 42, color: colors.textMuted),
          const SizedBox(height: 12),
          Text(
            isOwnProfile ? 'No posts yet' : 'No public posts yet',
            style: context.pStrong.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            isOwnProfile
                ? 'Your published shorts will appear here.'
                : 'This user has no visible posts yet.',
            textAlign: TextAlign.center,
            style: context.pMuted,
          ),
        ],
      ),
    );
  }
}

final _profileViewDataProvider =
    FutureProvider.family<_ProfileViewData, _ProfileRequest>((ref, request) {
      return _ProfileLoader(ref).load(request);
    });

class _ProfileLoader {
  final Ref ref;

  const _ProfileLoader(this.ref);

  Future<_ProfileViewData> load(_ProfileRequest request) async {
    final isOwnProfile = _sameUser(
      request.targetUser,
      request.currentUserEmail,
    );

    final profileFuture = _loadProfilePayload(request);
    final followingFuture = _loadConnectionTotal(
      ApiEndpoints.getFollowingEndpoint,
      request.targetUser,
    );
    final followersFuture = _loadConnectionTotal(
      ApiEndpoints.getFollowsEndpoint,
      request.targetUser,
    );
    final friendsFuture = _loadConnectionTotal(
      ApiEndpoints.getFriendsEndpoint,
      request.targetUser,
    );
    final postsFuture = _loadPosts(request.targetUser);
    final relationshipFuture = isOwnProfile
        ? Future<_RelationshipLite>.value(const _RelationshipLite.self())
        : _loadRelationship(request.targetUser);

    final results = await Future.wait<dynamic>([
      profileFuture,
      followingFuture,
      followersFuture,
      friendsFuture,
      postsFuture,
      relationshipFuture,
    ]);

    final profile = results[0] as Map<String, dynamic>;
    final following = results[1] as int?;
    final followers = results[2] as int?;
    final friends = results[3] as int?;
    final posts = results[4] as List<Short>;
    final relationship = results[5] as _RelationshipLite;

    final profileBelongsToTarget = _profileBelongsToTarget(
      profile,
      request.targetUser,
      isOwnProfile,
    );

    final displayName = _firstNonEmpty([
      if (profileBelongsToTarget) profile['display_name'],
      if (profileBelongsToTarget) profile['full_name'],
      if (profileBelongsToTarget) profile['name'],
      request.fallbackDisplayName,
      isOwnProfile ? request.currentDisplayName : null,
      request.targetUser,
    ]);

    final rawAvatar = _firstNonEmpty([
      if (profileBelongsToTarget) profile['avatar'],
      if (profileBelongsToTarget) profile['user_image'],
      if (profileBelongsToTarget) profile['image'],
      request.fallbackAvatar,
      isOwnProfile ? request.currentAvatar : null,
    ]);

    final bio = _firstNonEmpty([
      if (profileBelongsToTarget) profile['bio'],
      if (profileBelongsToTarget) profile['about'],
      if (profileBelongsToTarget) profile['description'],
      isOwnProfile ? request.currentBio : null,
    ]);

    return _ProfileViewData(
      user: request.targetUser,
      displayName: displayName,
      username: _usernameFromEmail(request.targetUser),
      avatarUrl: buildFileUrl(rawAvatar),
      bio: bio,
      isOwnProfile: isOwnProfile,
      followingCount: following ?? _int(profile['total_following']) ?? 0,
      followersCount:
          followers ??
          _int(profile['total_followers']) ??
          relationship.targetTotalFollowers ??
          0,
      friendsCount: friends ?? _int(profile['total_friends']) ?? 0,
      likesCount:
          _int(profile['total_likes']) ??
          _int(profile['like_count']) ??
          posts.fold<int>(0, (sum, short) => sum + short.metrics.likeCount),
      posts: posts,
      isFollowing: relationship.isFollowing,
      followActionLabel: relationship.actionLabel,
    );
  }

  Future<Map<String, dynamic>> _loadProfilePayload(
    _ProfileRequest request,
  ) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            ApiEndpoints.getProfileEndpoint,
            queryParameters: _targetQuery(request.targetUser),
          );
      final unwrapped = unwrapFrappe(res);

      if (unwrapped.isLeft) return <String, dynamic>{};

      final raw = _extractData(unwrapped.rightOrNull);
      if (raw is Map) return Map<String, dynamic>.from(raw);
    } catch (_) {}

    return <String, dynamic>{};
  }

  Future<int?> _loadConnectionTotal(String endpoint, String targetUser) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            endpoint,
            queryParameters: {
              ..._targetQuery(targetUser),
              'limit': 1,
              'start': 0,
            },
          );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return null;

      final raw = _extractData(unwrapped.rightOrNull);
      if (raw is Map) return _int(raw['total']);
    } catch (_) {}

    return null;
  }

  Future<_RelationshipLite> _loadRelationship(String targetUser) async {
    try {
      final relationship = await ref
          .read(socialRepositoryProvider)
          .getRelationshipStatus(targetUser: targetUser);

      if (relationship.isRight) {
        final value = relationship.rightOrNull!;
        return _RelationshipLite(
          isFollowing: value.isFollowing,
          actionLabel: value.actionLabel,
          targetTotalFollowers: value.targetTotalFollowers,
        );
      }
    } catch (_) {}

    return const _RelationshipLite(
      isFollowing: false,
      actionLabel: 'Follow',
      targetTotalFollowers: null,
    );
  }

  Future<List<Short>> _loadPosts(String targetUser) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            ApiEndpoints.myShorts,
            queryParameters: {
              ..._targetQuery(targetUser),
              'owner': targetUser,
              'limit': 30,
            },
          );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return const <Short>[];

      final data = _extractData(unwrapped.rightOrNull);
      final rawItems = data is Map ? data['items'] : null;

      if (rawItems is! List) return const <Short>[];

      return rawItems
          .whereType<Map>()
          .map((item) => ShortModel.fromJson(Map<String, dynamic>.from(item)))
          .map(ShortMapper.toDomain)
          .where((short) {
            final creatorUser = short.creator.user.trim().toLowerCase();
            if (creatorUser.isEmpty) return true;
            return creatorUser == targetUser.trim().toLowerCase();
          })
          .toList(growable: false);
    } catch (_) {
      return const <Short>[];
    }
  }

  static Map<String, dynamic> _targetQuery(String targetUser) {
    return {'user': targetUser, 'target_user': targetUser};
  }

  static dynamic _extractData(dynamic payload) {
    if (payload is Map && payload['data'] is Map) return payload['data'];
    if (payload is Map && payload['message'] is Map) {
      final message = payload['message'] as Map;
      if (message['data'] is Map) return message['data'];
      return message;
    }
    return payload;
  }

  static bool _profileBelongsToTarget(
    Map<String, dynamic> profile,
    String targetUser,
    bool isOwnProfile,
  ) {
    if (isOwnProfile) return true;

    final target = targetUser.trim().toLowerCase();
    final identity = _firstNonEmpty([
      profile['user'],
      profile['email'],
      profile['target_user'],
    ]).trim().toLowerCase();

    if (identity.isEmpty) return false;
    return identity == target;
  }

  static bool _sameUser(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final clean = value?.toString().trim();
      if (clean != null && clean.isNotEmpty && clean.toLowerCase() != 'null') {
        return clean;
      }
    }
    return '';
  }

  static int? _int(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

@immutable
class _ProfileRequest {
  final String targetUser;
  final String currentUserEmail;
  final String currentDisplayName;
  final String currentAvatar;
  final String? currentBio;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const _ProfileRequest({
    required this.targetUser,
    required this.currentUserEmail,
    required this.currentDisplayName,
    required this.currentAvatar,
    this.currentBio,
    this.fallbackDisplayName,
    this.fallbackAvatar,
  });

  @override
  bool operator ==(Object other) {
    return other is _ProfileRequest &&
        other.targetUser == targetUser &&
        other.currentUserEmail == currentUserEmail &&
        other.currentDisplayName == currentDisplayName &&
        other.currentAvatar == currentAvatar &&
        other.currentBio == currentBio &&
        other.fallbackDisplayName == fallbackDisplayName &&
        other.fallbackAvatar == fallbackAvatar;
  }

  @override
  int get hashCode => Object.hash(
    targetUser,
    currentUserEmail,
    currentDisplayName,
    currentAvatar,
    currentBio,
    fallbackDisplayName,
    fallbackAvatar,
  );
}

@immutable
class _ProfileViewData {
  final String user;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String bio;
  final bool isOwnProfile;
  final int followingCount;
  final int followersCount;
  final int friendsCount;
  final int likesCount;
  final List<Short> posts;
  final bool isFollowing;
  final String followActionLabel;

  const _ProfileViewData({
    required this.user,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.isOwnProfile,
    required this.followingCount,
    required this.followersCount,
    required this.friendsCount,
    required this.likesCount,
    required this.posts,
    required this.isFollowing,
    required this.followActionLabel,
  });

  factory _ProfileViewData.fallback({
    required String targetUser,
    required bool isOwnProfile,
    required String currentDisplayName,
    required String currentAvatar,
    required String? currentBio,
    String? fallbackDisplayName,
    String? fallbackAvatar,
  }) {
    final displayName = _ProfileLoader._firstNonEmpty([
      fallbackDisplayName,
      isOwnProfile ? currentDisplayName : null,
      targetUser,
    ]);
    final avatar = _ProfileLoader._firstNonEmpty([
      fallbackAvatar,
      isOwnProfile ? currentAvatar : null,
    ]);

    return _ProfileViewData(
      user: targetUser,
      displayName: displayName,
      username: _usernameFromEmail(targetUser),
      avatarUrl: buildFileUrl(avatar),
      bio: isOwnProfile ? (currentBio?.trim() ?? '') : '',
      isOwnProfile: isOwnProfile,
      followingCount: 0,
      followersCount: 0,
      friendsCount: 0,
      likesCount: 0,
      posts: const <Short>[],
      isFollowing: false,
      followActionLabel: 'Follow',
    );
  }
}

@immutable
class _RelationshipLite {
  final bool isFollowing;
  final String actionLabel;
  final int? targetTotalFollowers;

  const _RelationshipLite({
    required this.isFollowing,
    required this.actionLabel,
    required this.targetTotalFollowers,
  });

  const _RelationshipLite.self()
    : isFollowing = false,
      actionLabel = '',
      targetTotalFollowers = null;
}

String _usernameFromEmail(String value) {
  final clean = value.trim();
  if (clean.contains('@')) return clean.split('@').first;
  return clean;
}
