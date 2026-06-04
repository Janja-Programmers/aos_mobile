import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';

class SocialConnectionsController
    extends StateNotifier<SocialConnectionsState> {
  final SocialRepository _repository;
  final String? _targetUser;

  SocialConnectionsController(
    this._repository, {
    SocialConnectionsTab initialTab = SocialConnectionsTab.followers,
    String? targetUser,
  }) : _targetUser = targetUser?.trim().isNotEmpty == true
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

    state = state.copyWith(
      selectedTab: tab,
      query: '',
      isLoading: true,
      clearError: true,
      items: const [],
    );

    await loadTab(tab);
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  Future<void> refresh() async {
    await _loadCounts();
    await loadTab(state.selectedTab, refresh: true);
  }

  Future<void> loadTab(SocialConnectionsTab tab, {bool refresh = false}) async {
    state = state.copyWith(isLoading: !refresh, clearError: true);

    final result = switch (tab) {
      SocialConnectionsTab.following => await _repository.getFollowing(
        targetUser: _targetUser,
      ),
      SocialConnectionsTab.followers => await _repository.getFollowers(
        targetUser: _targetUser,
      ),
      SocialConnectionsTab.friends => await _repository.getFriends(
        targetUser: _targetUser,
      ),
    };

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialConnectionsController -> loadTab failed: ${failure.message}',
      );

      state = state.copyWith(isLoading: false, errorMessage: failure.message);
      return;
    }

    final page = result.rightOrNull!;

    state = state.copyWith(
      isLoading: false,
      items: page.items,
      clearError: true,
      followingCount: tab == SocialConnectionsTab.following ? page.total : null,
      followersCount: tab == SocialConnectionsTab.followers ? page.total : null,
      friendsCount: tab == SocialConnectionsTab.friends ? page.total : null,
    );
  }

  Future<void> _loadCounts() async {
    final results = await Future.wait([
      _repository.getFollowing(limit: 1, start: 0, targetUser: _targetUser),
      _repository.getFollowers(limit: 1, start: 0, targetUser: _targetUser),
      _repository.getFriends(limit: 1, start: 0, targetUser: _targetUser),
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
}
