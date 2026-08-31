part of 'profile_screen.dart';

class _ProfileScaffold extends ConsumerStatefulWidget {
  final _ProfileViewData data;
  final String contentUser;
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
    required this.contentUser,
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
  ConsumerState<_ProfileScaffold> createState() => _ProfileScaffoldState();
}

class _ProfileScaffoldState extends ConsumerState<_ProfileScaffold> {
  _ProfilePanel _selectedPanel = _ProfilePanel.posts;
  List<Short> _panelItems = const <Short>[];
  bool _panelLoading = false;
  bool _messageLoading = false;
  bool _followLoading = false;
  int _panelRequestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _panelItems = _itemsForPanel(widget.data, _selectedPanel);
    _schedulePanelLoad();
  }

  @override
  void didUpdateWidget(covariant _ProfileScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool userChanged = oldWidget.contentUser != widget.contentUser;
    final bool becameReady = oldWidget.isLoading && !widget.isLoading;
    final bool availabilityChanged =
        oldWidget.data.contentAvailable != widget.data.contentAvailable;
    final bool ownershipChanged =
        oldWidget.data.isOwnProfile != widget.data.isOwnProfile;
    final bool panelBecameUnavailable =
        !widget.data.isOwnProfile &&
        (_selectedPanel == _ProfilePanel.privateShorts ||
            _selectedPanel == _ProfilePanel.saved ||
            _selectedPanel == _ProfilePanel.liked);

    if (userChanged || panelBecameUnavailable) {
      _selectedPanel = _ProfilePanel.posts;
    }

    if (userChanged ||
        becameReady ||
        availabilityChanged ||
        ownershipChanged ||
        panelBecameUnavailable) {
      _panelRequestGeneration += 1;
      _panelLoading = false;
      _panelItems = _itemsForPanel(widget.data, _selectedPanel);
      _schedulePanelLoad();
    }
  }

  @override
  void dispose() {
    _panelRequestGeneration += 1;
    super.dispose();
  }

  _ProfilePanelRequest _panelRequest(_ProfileViewData data) {
    return _ProfilePanelRequest(
      targetUser: widget.contentUser,
      isOwnProfile: data.isOwnProfile,
      panel: _selectedPanel,
    );
  }

  void _schedulePanelLoad() {
    if (widget.isLoading || !widget.data.contentAvailable) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_loadSelectedPanel());
    });
  }

  Future<void> _loadSelectedPanel({bool forceRefresh = false}) async {
    if (widget.isLoading || !widget.data.contentAvailable) {
      if (!mounted) return;
      setState(() {
        _panelLoading = false;
        _panelItems = _itemsForPanel(widget.data, _selectedPanel);
      });
      return;
    }

    final _ProfilePanelRequest request = _panelRequest(widget.data);
    final int generation = ++_panelRequestGeneration;

    if (forceRefresh) {
      ref.invalidate(_profilePanelProvider(request));
    }

    if (mounted) {
      setState(() {
        _panelLoading = true;
        _panelItems = _itemsForPanel(widget.data, _selectedPanel);
      });
    }

    try {
      final List<Short> items = await ref.read(
        _profilePanelProvider(request).future,
      );
      if (!mounted || generation != _panelRequestGeneration) return;
      setState(() {
        _panelItems = items;
        _panelLoading = false;
      });
    } catch (_) {
      if (!mounted || generation != _panelRequestGeneration) return;
      setState(() {
        _panelItems = const <Short>[];
        _panelLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await widget.onRefresh();
    if (!mounted) return;
    await _loadSelectedPanel(forceRefresh: true);
  }

  void _selectPanel(_ProfilePanel panel) {
    if (_selectedPanel == panel) return;

    _panelRequestGeneration += 1;
    setState(() {
      _selectedPanel = panel;
      _panelLoading = false;
      _panelItems = _itemsForPanel(widget.data, panel);
    });
    unawaited(_loadSelectedPanel());
  }

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
    final List<Short> selectedItems = _panelItems;
    final bool panelLoading = widget.isLoading || _panelLoading;

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
        onRefresh: _handleRefresh,
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
                onFollowingTap: data.isOwnProfile
                    ? () {
                        SocialNavigation.toSocialConnectionsScreen(
                          context,
                          tab: SocialConnectionsTab.following,
                          title: data.displayName,
                        );
                      }
                    : null,
                onFollowersTap: data.isOwnProfile
                    ? () {
                        SocialNavigation.toSocialConnectionsScreen(
                          context,
                          title: data.displayName,
                        );
                      }
                    : null,
                isLive: data.isLive,
                liveId: data.liveId,
                // Do not expose profile mutations while the authoritative
                // profile payload is still loading. This prevents fallback or
                // stale auth data from seeding an edit operation.
                onAvatarTap: widget.isLoading ? null : widget.onAvatarTap,
                onEditTap: widget.isLoading ? null : widget.onEditTap,
                onMessageTap: widget.onMessageTap == null
                    ? null
                    : _handleMessageTap,
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
                  isOwnProfile: data.isOwnProfile,
                  onChanged: _selectPanel,
                ),
                backgroundColor: colors.surface,
              ),
            ),
            if (panelLoading)
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
