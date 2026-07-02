import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';
import 'package:flutter_riverpod/legacy.dart';

class SocialConnectionsController
    extends StateNotifier<SocialConnectionsState> {
  final SocialRepository _repository;
  final String? _targetUser;

  Timer? _searchDebounce;
  int _requestSerial = 0;

  SocialConnectionsController(
    this._repository, {
    SocialConnectionsTab initialTab = SocialConnectionsTab.followers,
    String? targetUser,
  }) : _targetUser = targetUser?.trim().isNotEmpty ?? false
           ? targetUser!.trim()
           : null,
       super(SocialConnectionsState(selectedTab: initialTab)) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    await _loadCounts();
    await loadTab(state.selectedTab);
  }

  Future<void> changeTab(SocialConnectionsTab tab) async {
    if (state.selectedTab == tab) return;

    _searchDebounce?.cancel();

    state = state.copyWith(
      selectedTab: tab,
      query: '',
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      nextStart: 0,
      clearError: true,
      items: const [],
    );

    await loadTab(tab);
  }

  void updateQuery(String query) {
    final clean = query.trim();

    if (clean == state.query) return;

    _searchDebounce?.cancel();

    state = state.copyWith(
      query: clean,
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      nextStart: 0,
      clearError: true,
      items: const [],
    );

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      loadTab(state.selectedTab, refresh: true);
    });
  }

  Future<void> refresh() async {
    await _loadCounts();
    await loadTab(state.selectedTab, refresh: true);
  }

  Future<void> loadTab(SocialConnectionsTab tab, {bool refresh = false}) async {
    final serial = ++_requestSerial;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      nextStart: 0,
      clearError: true,
      items: refresh ? const [] : state.items,
    );

    final result = await _fetchTab(tab: tab, start: 0);

    if (!mounted || serial != _requestSerial) return;

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialConnectionsController -> loadTab failed: ${failure.message}',
      );

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: failure.message,
      );
      return;
    }

    final page = result.rightOrNull!;

    state = state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      items: page.items,
      hasMore: page.hasMore,
      nextStart: page.start + page.items.length,
      clearError: true,
      followingCount: tab == SocialConnectionsTab.following ? page.total : null,
      followersCount: tab == SocialConnectionsTab.followers ? page.total : null,
      friendsCount: tab == SocialConnectionsTab.friends ? page.total : null,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final tab = state.selectedTab;
    final start = state.nextStart;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    final result = await _fetchTab(tab: tab, start: start);

    if (!mounted) return;

    if (result.isLeft) {
      final failure = result.leftOrNull!;
      appLogger.w(
        'SocialConnectionsController -> loadMore failed: ${failure.message}',
      );
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      );
      return;
    }

    final page = result.rightOrNull!;
    final byUser = <String, SocialFriend>{
      for (final item in state.items) item.user: item,
    };
    for (final item in page.items) {
      byUser[item.user] = item;
    }

    state = state.copyWith(
      isLoadingMore: false,
      items: List.unmodifiable(byUser.values),
      hasMore: page.hasMore,
      nextStart: page.start + page.items.length,
      clearError: true,
      followingCount: tab == SocialConnectionsTab.following ? page.total : null,
      followersCount: tab == SocialConnectionsTab.followers ? page.total : null,
      friendsCount: tab == SocialConnectionsTab.friends ? page.total : null,
    );
  }

  Future<Either<Failure, SocialFriendsPage>> _fetchTab({
    required SocialConnectionsTab tab,
    required int start,
  }) {
    final query = state.query.trim().isEmpty ? null : state.query.trim();

    return switch (tab) {
      SocialConnectionsTab.following => _repository.getFollowing(
        start: start,
        targetUser: _targetUser,
        query: query,
      ),
      SocialConnectionsTab.followers => _repository.getFollowers(
        start: start,
        targetUser: _targetUser,
        query: query,
      ),
      SocialConnectionsTab.friends => _repository.getFriends(
        start: start,
        targetUser: _targetUser,
        query: query,
      ),
    };
  }

  Future<void> _loadCounts() async {
    final results = await Future.wait([
      _repository.getFollowing(limit: 1, targetUser: _targetUser),
      _repository.getFollowers(limit: 1, targetUser: _targetUser),
      _repository.getFriends(limit: 1, targetUser: _targetUser),
    ]);

    int following = state.followingCount;
    int followers = state.followersCount;
    int friends = state.friendsCount;

    final followingRes = results[0];
    final followersRes = results[1];
    final friendsRes = results[2];

    if (followingRes.isRight) {
      following = followingRes.rightOrNull?.total ?? following;
    }

    if (followersRes.isRight) {
      followers = followersRes.rightOrNull?.total ?? followers;
    }

    if (friendsRes.isRight) {
      friends = friendsRes.rightOrNull?.total ?? friends;
    }

    state = state.copyWith(
      followingCount: following,
      followersCount: followers,
      friendsCount: friends,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
