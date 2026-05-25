import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';

class SocialFriendsController
    extends StateNotifier<AsyncValue<SocialFriendsPage>> {
  final SocialRepository _repository;

  SocialFriendsController(this._repository)
    : super(const AsyncData(SocialFriendsPage.empty())) {
    loadFriends();
  }

  Future<void> loadFriends({int limit = 20, int start = 0}) async {
    state = const AsyncLoading();

    final result = await _repository.getFriends(limit: limit, start: start);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialFriendsController -> loadFriends failed: ${failure.message}',
      );

      state = AsyncError(failure, StackTrace.current);
      return;
    }

    state = AsyncData(result.rightOrNull!);
  }

  Future<void> refreshFriends({int limit = 20}) async {
    final previous = state;

    final result = await _repository.getFriends(limit: limit, start: 0);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialFriendsController -> refreshFriends failed: ${failure.message}',
      );

      // Keep old data visible if refresh fails.
      if (previous is AsyncData<SocialFriendsPage>) {
        state = previous;
      } else {
        state = AsyncError(failure, StackTrace.current);
      }

      return;
    }

    state = AsyncData(result.rightOrNull!);
  }
}
