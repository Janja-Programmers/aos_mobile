import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/social/application/controllers/social_followers_controller.dart';
import 'package:africaonlinestores/features/social/application/controllers/social_following_controllers.dart';
import 'package:africaonlinestores/features/social/application/controllers/social_friend_controllers.dart';
import 'package:africaonlinestores/features/social/application/controllers/social_relationship_controller.dart';
import 'package:africaonlinestores/features/social/data/social_api.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';
import 'package:africaonlinestores/features/social/domain/social_relationship.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final socialApiProvider = Provider<SocialApi>((ref) {
  return SocialApi(ref.read(apiClientProvider));
});

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(ref.read(socialApiProvider));
});

final socialFriendsControllerProvider =
    StateNotifierProvider<
      SocialFriendsController,
      AsyncValue<SocialFriendsPage>
    >((ref) {
      return SocialFriendsController(ref.read(socialRepositoryProvider));
    });

final socialFollowersControllerProvider =
    StateNotifierProvider<
      SocialFollowersController,
      AsyncValue<SocialFriendsPage>
    >((ref) {
      return SocialFollowersController(ref.read(socialRepositoryProvider));
    });

final socialFollowingControllerProvider =
    StateNotifierProvider<
      SocialFollowingController,
      AsyncValue<SocialFriendsPage>
    >((ref) {
      return SocialFollowingController(ref.read(socialRepositoryProvider));
    });

final socialRelationshipControllerProvider =
    StateNotifierProvider<
      SocialRelationshipController,
      AsyncValue<Map<String, SocialRelationship>>
    >((ref) {
      return SocialRelationshipController(ref.read(socialRepositoryProvider));
    });
