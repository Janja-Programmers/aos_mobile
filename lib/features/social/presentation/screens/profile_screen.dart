import 'dart:async';

import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/presentation/widgets/profile_edit_sheet.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/features/social/safety/presentation/widgets/user_safety_sheet.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

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
      currentIsVerified: currentUser.isVerified,
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
          currentIsVerified: currentUser.isVerified,
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
          currentIsVerified: currentUser.isVerified,
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
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const ProfileEditSheet(),
      ),
    );
  }

  static Future<void> _shareProfile(_ProfileViewData data) async {
    final cleanUser = Uri.encodeQueryComponent(data.user.trim());
    final url = '${AppConfig.normalizedBaseUrl}/profile?user=$cleanUser';
    final title = data.displayName.trim().isNotEmpty
        ? data.displayName.trim()
        : 'AOS profile';

    await SharePlus.instance.share(
      ShareParams(text: 'View $title on AOS\n$url', subject: title),
    );
  }

  static void _showSafetySheet(BuildContext context, _ProfileViewData data) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => UserSafetySheet(
          targetUser: data.user,
          displayName: data.displayName,
        ),
      ),
    );
  }
}

enum _ProfilePanel { posts, saved, liked }

extension _ProfilePanelX on _ProfilePanel {
  String get label {
    switch (this) {
      case _ProfilePanel.posts:
        return 'Posts';
      case _ProfilePanel.saved:
        return 'Saved';
      case _ProfilePanel.liked:
        return 'Liked';
    }
  }

  IconData get icon {
    switch (this) {
      case _ProfilePanel.posts:
        return Icons.grid_view_rounded;
      case _ProfilePanel.saved:
        return Icons.bookmark_border_rounded;
      case _ProfilePanel.liked:
        return Icons.favorite_border_rounded;
    }
  }
}

class _ProfileScaffold extends StatefulWidget {
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
  State<_ProfileScaffold> createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<_ProfileScaffold> {
  _ProfilePanel _selectedPanel = _ProfilePanel.posts;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final data = widget.data;
    final selectedItems = _itemsForPanel(data, _selectedPanel);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _ProfileAppBar(
        title: data.isOwnProfile ? 'Me' : data.displayName,
        onShareTap: widget.onShareTap,
        onMoreTap: data.isOwnProfile
            ? null
            : () => ProfileScreen._showSafetySheet(context, data),
      ),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                displayName: data.displayName,
                username: data.username,
                imageUrl: data.avatarUrl,
                bio: data.bio,
                isVerified: data.isVerified,
                isOwnProfile: data.isOwnProfile,
                followingCount: _formatCount(data.followingCount),
                followersCount: _formatCount(data.followersCount),
                likesCount: _formatCount(data.likesCount),
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
                    title: data.displayName,
                    user: data.user,
                  );
                },
                onEditTap: widget.onEditTap,
                onMessageTap: widget.onMessageTap,
                followActionLabel: data.followActionLabel,
                isFollowing: data.isFollowing,
                onFollowTap: widget.onFollowTap,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileTabsHeaderDelegate(
                child: _ProfileTabs(
                  selected: _selectedPanel,
                  onChanged: (panel) => setState(() => _selectedPanel = panel),
                ),
                backgroundColor: colors.surface,
              ),
            ),
            if (widget.isLoading)
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
            else if (selectedItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyProfilePanelView(
                  isOwnProfile: data.isOwnProfile,
                  panel: _selectedPanel,
                ),
              )
            else
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _ProfileGridItem(short: selectedItems[index]);
                }, childCount: selectedItems.length),
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

  static List<Short> _itemsForPanel(
    _ProfileViewData data,
    _ProfilePanel panel,
  ) {
    switch (panel) {
      case _ProfilePanel.posts:
        return data.posts;
      case _ProfilePanel.saved:
        return data.saved;
      case _ProfilePanel.liked:
        return data.liked;
    }
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
  final bool isVerified;
  final bool isOwnProfile;

  final String followingCount;
  final String followersCount;
  final String likesCount;

  final VoidCallback onFollowingTap;
  final VoidCallback onFollowersTap;
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
    required this.isVerified,
    required this.isOwnProfile,
    required this.followingCount,
    required this.followersCount,
    required this.likesCount,
    required this.onFollowingTap,
    required this.onFollowersTap,
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
        const SizedBox(height: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: colors.primary.withValues(alpha: 0.18),
              child: CircleAvatar(
                radius: 42,
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
            if (isOwnProfile)
              Positioned(
                right: -3,
                bottom: -3,
                child: GestureDetector(
                  onTap: onEditTap,
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
                ),
              ),
          ],
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
                Icon(
                  Icons.verified_rounded,
                  color: Colors.lightBlueAccent.shade400,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.pMuted.copyWith(fontSize: 14, height: 1.1),
        ),
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
            _ProfileStat(value: likesCount, label: 'Likes', onTap: () {}),
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
                  label: 'Edit profile',
                  icon: Icons.edit_outlined,
                  onTap: onEditTap,
                  expanded: true,
                  outlined: true,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _MainProfileActionButton(
                        label: 'Message',
                        icon: Icons.send_rounded,
                        onTap: onMessageTap,
                        expanded: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FollowProfileActionButton(
                      label: followActionLabel,
                      isFollowing: isFollowing,
                      onTap: onFollowTap,
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
  final bool expanded;
  final bool outlined;

  const _MainProfileActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.expanded = false,
    this.outlined = false,
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
      child: Row(
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
      onTap: onTap,
      child: expanded ? SizedBox(width: double.infinity, child: child) : child,
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
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(covariant _ProfileTabsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _ProfileTabs extends StatelessWidget {
  final _ProfilePanel selected;
  final ValueChanged<_ProfilePanel> onChanged;

  const _ProfileTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              for (final panel in _ProfilePanel.values)
                Expanded(
                  child: _TabIcon(
                    icon: panel.icon,
                    label: panel.label,
                    isSelected: selected == panel,
                    color: selected == panel
                        ? colors.primary
                        : colors.textMuted,
                    onTap: () => onChanged(panel),
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
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TabIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 5),
          Text(
            label,
            style: context.p.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: isSelected ? 34 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
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

    return ColoredBox(
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
      _ProfilePanel.saved => Icons.bookmark_border_rounded,
      _ProfilePanel.liked => Icons.favorite_border_rounded,
    };
    final title = switch (panel) {
      _ProfilePanel.posts =>
        isOwnProfile ? 'No posts yet' : 'No public posts yet',
      _ProfilePanel.saved => 'No saved posts yet',
      _ProfilePanel.liked => 'No liked posts yet',
    };
    final message = switch (panel) {
      _ProfilePanel.posts =>
        isOwnProfile
            ? 'Your published shorts will appear here.'
            : 'This user has no visible posts yet.',
      _ProfilePanel.saved =>
        isOwnProfile
            ? 'Saved shorts and posts will appear here.'
            : 'Saved posts are not public for this profile.',
      _ProfilePanel.liked =>
        isOwnProfile
            ? 'Liked shorts and posts will appear here.'
            : 'Liked posts are not public for this profile.',
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
    final postsFuture = _loadPosts(
      request.targetUser,
      isOwnProfile: isOwnProfile,
    );
    final savedFuture = isOwnProfile
        ? _loadShortPanel(ApiEndpoints.savedShorts, request.targetUser)
        : Future<List<Short>>.value(const <Short>[]);
    final likedFuture = isOwnProfile
        ? _loadShortPanel(ApiEndpoints.likedShorts, request.targetUser)
        : Future<List<Short>>.value(const <Short>[]);
    final relationshipFuture = isOwnProfile
        ? Future<_RelationshipLite>.value(const _RelationshipLite.self())
        : _loadRelationship(request.targetUser);

    final results = await Future.wait<dynamic>([
      profileFuture,
      followingFuture,
      followersFuture,
      friendsFuture,
      postsFuture,
      savedFuture,
      likedFuture,
      relationshipFuture,
    ]);

    final profile = results[0] as Map<String, dynamic>;
    final following = results[1] as int?;
    final followers = results[2] as int?;
    final friends = results[3] as int?;
    final posts = results[4] as List<Short>;
    final saved = results[5] as List<Short>;
    final liked = results[6] as List<Short>;
    final relationship = results[7] as _RelationshipLite;

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

    final isVerified =
        profileBelongsToTarget &&
        (_bool(profile['is_verified']) ||
            _bool(profile['verified']) ||
            _bool(profile['identity_verified']) ||
            _bool(profile['is_identity_verified']));

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
      isVerified: isVerified || (isOwnProfile && request.currentIsVerified),
      posts: posts,
      saved: saved,
      liked: liked,
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
      return asJsonMap(raw);
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
      return _int(raw['total']);
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

  Future<List<Short>> _loadPosts(
    String targetUser, {
    required bool isOwnProfile,
  }) {
    return _loadShortPanel(
      isOwnProfile ? ApiEndpoints.myShorts : ApiEndpoints.userShorts,
      targetUser,
      onlyCreator: true,
    );
  }

  Future<List<Short>> _loadShortPanel(
    String endpoint,
    String targetUser, {
    bool onlyCreator = false,
  }) async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(
            endpoint,
            queryParameters: {
              ..._targetQuery(targetUser),
              'owner': targetUser,
              'limit': 30,
            },
          );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return const <Short>[];

      final data = _extractData(unwrapped.rightOrNull);
      final rawItems = data['items'] ?? data['shorts'] ?? data['data'];

      final list = asJsonMapList(rawItems)
          .map(ShortModel.fromJson)
          .map(ShortMapper.toDomain)
          .toList(growable: false);

      if (!onlyCreator) return list;

      return list
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

  static Map<String, dynamic> _extractData(Object? payload) {
    final data = asJsonMap(payload);
    final innerData = asJsonMap(data['data']);
    if (innerData.isNotEmpty) return innerData;

    final message = asJsonMap(data['message']);
    if (message.isNotEmpty) {
      final messageData = asJsonMap(message['data']);
      return messageData.isNotEmpty ? messageData : message;
    }

    return data;
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

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final clean = value?.toString().trim();
      if (clean != null && clean.isNotEmpty && clean.toLowerCase() != 'null') {
        return clean;
      }
    }
    return '';
  }

  static bool _bool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    final clean = value.toString().trim().toLowerCase();
    return clean == '1' ||
        clean == 'true' ||
        clean == 'yes' ||
        clean == 'approved';
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
  final bool currentIsVerified;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const _ProfileRequest({
    required this.targetUser,
    required this.currentUserEmail,
    required this.currentDisplayName,
    required this.currentAvatar,
    this.currentBio,
    required this.currentIsVerified,
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
        other.currentIsVerified == currentIsVerified &&
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
    currentIsVerified,
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
  final bool isVerified;
  final List<Short> posts;
  final List<Short> saved;
  final List<Short> liked;
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
    required this.isVerified,
    required this.posts,
    required this.saved,
    required this.liked,
    required this.isFollowing,
    required this.followActionLabel,
  });

  factory _ProfileViewData.fallback({
    required String targetUser,
    required bool isOwnProfile,
    required String currentDisplayName,
    required String currentAvatar,
    required String? currentBio,
    required bool currentIsVerified,
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
      isVerified: isOwnProfile && currentIsVerified,
      posts: const <Short>[],
      saved: const <Short>[],
      liked: const <Short>[],
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
