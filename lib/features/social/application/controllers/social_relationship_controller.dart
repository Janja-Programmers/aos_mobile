import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_relationship.dart';

class SocialRelationshipController
    extends StateNotifier<AsyncValue<Map<String, SocialRelationship>>> {
  final SocialRepository _repository;

  SocialRelationshipController(this._repository) : super(const AsyncData({}));

  Future<void> loadRelationshipStatus({required String targetUser}) async {
    final cleanTarget = targetUser.trim();

    if (cleanTarget.isEmpty) return;

    final current = _currentRelationships();

    state = AsyncData(current);

    final result = await _repository.getRelationshipStatus(
      targetUser: cleanTarget,
    );

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialRelationshipController -> loadRelationshipStatus failed: ${failure.message}',
      );

      state = AsyncError(failure, StackTrace.current);
      return;
    }

    final relationship = result.rightOrNull!;

    state = AsyncData({..._currentRelationships(), cleanTarget: relationship});
  }

  Future<void> toggleFollow({required String targetUser}) async {
    final cleanTarget = targetUser.trim();

    if (cleanTarget.isEmpty) return;

    final previous = _currentRelationships();

    final result = await _repository.toggleFollow(targetUser: cleanTarget);

    if (result.isLeft) {
      final failure = result.leftOrNull!;

      appLogger.w(
        'SocialRelationshipController -> toggleFollow failed: ${failure.message}',
      );

      if (previous.isNotEmpty) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(failure, StackTrace.current);
      }

      return;
    }

    final relationship = result.rightOrNull!;

    state = AsyncData({...previous, cleanTarget: relationship});
  }

  SocialRelationship? getRelationship(String targetUser) {
    final cleanTarget = targetUser.trim();

    if (cleanTarget.isEmpty) return null;

    return state.maybeWhen(
      data: (relationships) => relationships[cleanTarget],
      orElse: () => null,
    );
  }

  Map<String, SocialRelationship> _currentRelationships() {
    return state.maybeWhen(
      data: (relationships) =>
          Map<String, SocialRelationship>.from(relationships),
      orElse: () => <String, SocialRelationship>{},
    );
  }
}
