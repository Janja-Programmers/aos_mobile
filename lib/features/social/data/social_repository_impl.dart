import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/social/data/social_api.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';

abstract class SocialRepository {
  Future<Either<Failure, SocialFriendsPage>> getFriends({
    int limit = 20,
    int start = 0,
  });
}

class SocialRepositoryImpl implements SocialRepository {
  final SocialApi api;

  const SocialRepositoryImpl(this.api);

  @override
  Future<Either<Failure, SocialFriendsPage>> getFriends({
    int limit = 20,
    int start = 0,
  }) {
    return api.getFriends(limit: limit, start: start);
  }
}
