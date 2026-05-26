import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';

class SocialFollowersController
    extends StateNotifier<AsyncValue<SocialFriendsPage>> {
  final SocialRepository _repository;

  SocialFollowersController(this._repository)
    : super(const AsyncData(SocialFriendsPage.empty())) {
    loadFollowers();
  }

  Future<void> loadFollowers({int limit = 20, int start = 0}) async {
    state = const AsyncLoading();

    final result = await _repository.getFollowers(limit: limit, start: start);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialFollowersController -> loadFollowers failed: ${failure.message}',
      );

      state = AsyncError(failure, StackTrace.current);
      return;
    }

    state = AsyncData(result.rightOrNull!);
  }

  Future<void> refreshFollowers({int limit = 20}) async {
    final previous = state;

    final result = await _repository.getFollowers(limit: limit, start: 0);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialFollowersController -> refreshFollowers failed: ${failure.message}',
      );

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
