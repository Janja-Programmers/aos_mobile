import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/social/data/social_api.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';
import 'package:africaonlinestores/features/social/domain/social_relationship.dart';

abstract class SocialRepository {
  Future<Either<Failure, SocialFriendsPage>> getFollowers({
    int limit = 20,
    int start = 0,
    String? targetUser,
  });

  Future<Either<Failure, SocialFriendsPage>> getFollowing({
    int limit = 20,
    int start = 0,
    String? targetUser,
  });

  Future<Either<Failure, SocialFriendsPage>> getFriends({
    int limit = 20,
    int start = 0,
    String? targetUser,
  });

  Future<Either<Failure, SocialRelationship>> toggleFollow({
    required String targetUser,
  });

  Future<Either<Failure, SocialRelationship>> getRelationshipStatus({
    required String targetUser,
  });
}

class SocialRepositoryImpl implements SocialRepository {
  final SocialApi api;

  const SocialRepositoryImpl(this.api);

  @override
  Future<Either<Failure, SocialFriendsPage>> getFollowers({
    int limit = 20,
    int start = 0,
    String? targetUser,
  }) {
    return api.getFollowers(limit: limit, start: start, targetUser: targetUser);
  }

  @override
  Future<Either<Failure, SocialFriendsPage>> getFollowing({
    int limit = 20,
    int start = 0,
    String? targetUser,
  }) {
    return api.getFollowing(limit: limit, start: start, targetUser: targetUser);
  }

  @override
  Future<Either<Failure, SocialFriendsPage>> getFriends({
    int limit = 20,
    int start = 0,
    String? targetUser,
  }) {
    return api.getFriends(limit: limit, start: start, targetUser: targetUser);
  }

  @override
  Future<Either<Failure, SocialRelationship>> toggleFollow({
    required String targetUser,
  }) {
    return api.toggleFollow(targetUser: targetUser);
  }

  @override
  Future<Either<Failure, SocialRelationship>> getRelationshipStatus({
    required String targetUser,
  }) {
    return api.getRelationshipStatus(targetUser: targetUser);
  }
}
