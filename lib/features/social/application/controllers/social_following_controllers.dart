import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SocialFollowingController
    extends StateNotifier<AsyncValue<SocialFriendsPage>> {
  final SocialRepository _repository;

  SocialFollowingController(this._repository)
    : super(const AsyncData(SocialFriendsPage.empty())) {
    loadFollowing();
  }

  Future<void> loadFollowing({int limit = 20, int start = 0}) async {
    state = const AsyncLoading();

    final result = await _repository.getFollowing(limit: limit, start: start);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialFollowingController -> loadFollowing failed: ${failure.message}',
      );

      state = AsyncError(failure, StackTrace.current);
      return;
    }

    state = AsyncData(result.rightOrNull!);
  }

  Future<void> refreshFollowing({int limit = 20}) async {
    final previous = state;

    final result = await _repository.getFollowing(limit: limit);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialFollowingController -> refreshFollowing failed: ${failure.message}',
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
