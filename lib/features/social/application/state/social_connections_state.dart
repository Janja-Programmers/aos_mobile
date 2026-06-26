import 'package:flutter/foundation.dart';

import 'package:africaonlinestores/features/social/domain/social_friend.dart';

enum SocialConnectionsTab { following, followers, friends }

@immutable
class SocialConnectionsArgs {
  final SocialConnectionsTab initialTab;
  final String? targetUser;

  const SocialConnectionsArgs({
    this.initialTab = SocialConnectionsTab.followers,
    this.targetUser,
  });

  @override
  bool operator ==(Object other) {
    return other is SocialConnectionsArgs &&
        other.initialTab == initialTab &&
        other.targetUser == targetUser;
  }

  @override
  int get hashCode => Object.hash(initialTab, targetUser);
}

@immutable
class SocialConnectionsState {
  final SocialConnectionsTab selectedTab;
  final String query;

  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int nextStart;
  final String? errorMessage;

  final List<SocialFriend> items;

  final int followingCount;
  final int followersCount;
  final int friendsCount;

  const SocialConnectionsState({
    this.selectedTab = SocialConnectionsTab.followers,
    this.query = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextStart = 0,
    this.errorMessage,
    this.items = const [],
    this.followingCount = 0,
    this.followersCount = 0,
    this.friendsCount = 0,
  });

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;
  bool get isEmpty => !isLoading && !hasError && filteredItems.isEmpty;

  List<SocialFriend> get filteredItems {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return items;
    }

    return items.where((friend) {
      return friend.displayName.toLowerCase().contains(cleanQuery) ||
          friend.user.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  int get selectedCount {
    switch (selectedTab) {
      case SocialConnectionsTab.following:
        return followingCount;
      case SocialConnectionsTab.followers:
        return followersCount;
      case SocialConnectionsTab.friends:
        return friendsCount;
    }
  }

  SocialConnectionsState copyWith({
    SocialConnectionsTab? selectedTab,
    String? query,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? nextStart,
    String? errorMessage,
    bool clearError = false,
    List<SocialFriend>? items,
    int? followingCount,
    int? followersCount,
    int? friendsCount,
  }) {
    return SocialConnectionsState(
      selectedTab: selectedTab ?? this.selectedTab,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextStart: nextStart ?? this.nextStart,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      friendsCount: friendsCount ?? this.friendsCount,
    );
  }
}
