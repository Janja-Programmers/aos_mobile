import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';
import 'package:africaonlinestores/features/social/domain/social_relationship.dart';

typedef RelationshipHandler =
    Future<Either<Failure, SocialRelationship>> Function(String targetUser);

class ScriptedSocialRepository implements SocialRepository {
  ScriptedSocialRepository({
    RelationshipHandler? toggleFollowHandler,
    RelationshipHandler? relationshipStatusHandler,
  }) : _toggleFollowHandler = toggleFollowHandler,
       _relationshipStatusHandler = relationshipStatusHandler;

  final RelationshipHandler? _toggleFollowHandler;
  final RelationshipHandler? _relationshipStatusHandler;

  int toggleFollowCalls = 0;
  int relationshipStatusCalls = 0;

  @override
  Future<Either<Failure, SocialRelationship>> toggleFollow({
    required String targetUser,
  }) {
    toggleFollowCalls += 1;
    final RelationshipHandler? handler = _toggleFollowHandler;
    if (handler == null) {
      return Future<Either<Failure, SocialRelationship>>.value(
        Either.left(const Failure('No toggle-follow handler configured.')),
      );
    }
    return handler(targetUser);
  }

  @override
  Future<Either<Failure, SocialRelationship>> getRelationshipStatus({
    required String targetUser,
  }) {
    relationshipStatusCalls += 1;
    final RelationshipHandler? handler = _relationshipStatusHandler;
    if (handler == null) {
      return Future<Either<Failure, SocialRelationship>>.value(
        Either.left(const Failure('No relationship handler configured.')),
      );
    }
    return handler(targetUser);
  }

  @override
  Future<Either<Failure, SocialFriendsPage>> getFollowers({
    int limit = 20,
    int start = 0,
    String? query,
  }) async {
    return Either.right(const SocialFriendsPage.empty());
  }

  @override
  Future<Either<Failure, SocialFriendsPage>> getFollowing({
    int limit = 20,
    int start = 0,
    String? query,
  }) async {
    return Either.right(const SocialFriendsPage.empty());
  }

  @override
  Future<Either<Failure, SocialFriendsPage>> getFriends({
    int limit = 20,
    int start = 0,
    String? query,
  }) async {
    return Either.right(const SocialFriendsPage.empty());
  }
}
