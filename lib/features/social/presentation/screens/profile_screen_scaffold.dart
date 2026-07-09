part of 'profile_screen.dart';

class _ProfileScaffold extends StatefulWidget {
  final _ProfileViewData data;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback onActivityTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditTap;
  final Future<void> Function(BuildContext context)? onMessageTap;
  final VoidCallback? onSellerStoreTap;
  final Future<void> Function(BuildContext context)? onFollowTap;

  const _ProfileScaffold({
    required this.data,
    this.isLoading = false,
    required this.onRefresh,
    required this.onActivityTap,
    required this.onAvatarTap,
    required this.onEditTap,
    required this.onMessageTap,
    required this.onSellerStoreTap,
    required this.onFollowTap,
  });

  @override
  State<_ProfileScaffold> createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends State<_ProfileScaffold> {
  _ProfilePanel _selectedPanel = _ProfilePanel.posts;
  bool _messageLoading = false;
  bool _followLoading = false;

  Future<void> _handleMessageTap() async {
    final action = widget.onMessageTap;
    if (action == null || _messageLoading) return;

    setState(() => _messageLoading = true);
    try {
      await action(context);
    } finally {
      if (mounted) setState(() => _messageLoading = false);
    }
  }

  Future<void> _handleFollowTap() async {
    final action = widget.onFollowTap;
    if (action == null || _followLoading) return;

    setState(() => _followLoading = true);
    try {
      await action(context);
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final data = widget.data;
    final selectedItems = _itemsForPanel(data, _selectedPanel);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _ProfileAppBar(
        title: data.isOwnProfile ? 'Me' : data.displayName,
        onActivityTap: widget.onActivityTap,
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
                isLive: data.isLive,
                liveId: data.liveId,
                onAvatarTap: widget.onAvatarTap,
                onEditTap: widget.onEditTap,
                onMessageTap: _handleMessageTap,
                onSellerStoreTap: widget.onSellerStoreTap,
                followActionLabel: data.followActionLabel,
                isFollowing: data.isFollowing,
                messageLoading: _messageLoading,
                followLoading: _followLoading,
                onFollowTap: widget.onFollowTap == null
                    ? null
                    : _handleFollowTap,
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
                  return _ProfileGridItem(
                    short: selectedItems[index],
                    initialShorts: selectedItems,
                    initialIndex: index,
                  );
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
      case _ProfilePanel.reposted:
        return data.reposted;
      case _ProfilePanel.privateShorts:
        return data.privateShorts;
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

