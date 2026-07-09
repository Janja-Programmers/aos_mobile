import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/features/social/presentation/widgets/social_connection_tile.dart';
import 'package:africaonlinestores/features/social/presentation/widgets/social_connections_state_view.dart';
import 'package:africaonlinestores/features/social/safety/presentation/widgets/user_safety_sheet.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialConnectionsList extends ConsumerStatefulWidget {
  final SocialConnectionsState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;

  const SocialConnectionsList({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  ConsumerState<SocialConnectionsList> createState() =>
      _SocialConnectionsListState();
}

class _SocialConnectionsListState extends ConsumerState<SocialConnectionsList> {
  final Set<String> _pendingActionUsers = <String>{};

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return SocialConnectionsStateView.error(
        message: state.errorMessage ?? 'Something went wrong.',
        onRetry: widget.onRefresh,
      );
    }

    final items = state.filteredItems;

    if (items.isEmpty) {
      return SocialConnectionsStateView.empty(
        title: _emptyTitleForTab(state.selectedTab, state.query),
        message: _emptyMessageForTab(state.selectedTab, state.query),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 360 &&
              state.hasMore &&
              !state.isLoadingMore) {
            widget.onLoadMore();
          }
          return false;
        },
        child: ListView.separated(
          scrollCacheExtent: const ScrollCacheExtent.pixels(700),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 18),
          itemCount: items.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final friend = items[index];

            return RepaintBoundary(
              child: SocialConnectionTile(
                friend: friend,
                actionLoading: _pendingActionUsers.contains(friend.user),
                onTap: () {
                  SocialNavigation.toProfileScreen(
                    context,
                    user: friend.user,
                    displayName: friend.displayName,
                    avatar: friend.userImage,
                  );
                },
                onActionTap: () => _handleActionTap(friend),
                onMoreTap: () {
                  _showMoreActions(context, friend, widget.onRefresh);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleActionTap(SocialFriend friend) async {
    final cleanUser = friend.user.trim();

    if (cleanUser.isEmpty || _pendingActionUsers.contains(cleanUser)) return;

    setState(() => _pendingActionUsers.add(cleanUser));

    try {
      final result = await ref
          .read(socialRepositoryProvider)
          .toggleFollow(targetUser: cleanUser);

      if (!mounted) return;

      if (result.isLeft) {
        ShowSnack(
          context,
          result.leftOrNull?.message ?? 'Failed to update follow.',
        ).error();
        return;
      }

      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _pendingActionUsers.remove(cleanUser));
      }
    }
  }

  String _emptyTitleForTab(SocialConnectionsTab tab, String query) {
    if (query.trim().isNotEmpty) return 'No results found';

    switch (tab) {
      case SocialConnectionsTab.following:
        return 'No following yet';
      case SocialConnectionsTab.followers:
        return 'No followers yet';
      case SocialConnectionsTab.friends:
        return 'No friends yet';
    }
  }

  String _emptyMessageForTab(SocialConnectionsTab tab, String query) {
    if (query.trim().isNotEmpty) {
      return 'Try searching with another name or username.';
    }

    switch (tab) {
      case SocialConnectionsTab.following:
        return 'People you follow will appear here.';
      case SocialConnectionsTab.followers:
        return 'People following you will appear here.';
      case SocialConnectionsTab.friends:
        return 'Mutual followers will appear here.';
    }
  }

  Future<void> _showMoreActions(
    BuildContext context,
    SocialFriend friend,
    Future<void> Function() onRefresh,
  ) async {
    final colors = context.appColors;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                    Icons.person_outline_rounded,
                    color: colors.textPrimary,
                  ),
                  title: Text(
                    'View profile',
                    style: context.p.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    SocialNavigation.toProfileScreen(
                      context,
                      user: friend.user,
                      displayName: friend.displayName,
                      avatar: friend.userImage,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shield_outlined, color: colors.red),
                  title: Text(
                    'Report or block',
                    style: context.p.copyWith(
                      color: colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Use safety actions for this user',
                    style: AppTextStylesX(
                      context,
                    ).caption.copyWith(color: colors.textMuted),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: colors.elevated,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (_) => UserSafetySheet(
                        targetUser: friend.user,
                        displayName: friend.displayName,
                      ),
                    );
                    await onRefresh();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
