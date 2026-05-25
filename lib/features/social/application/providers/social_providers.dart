import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/social/application/controllers/social_friend_controllers.dart';
import 'package:africaonlinestores/features/social/data/social_api.dart';
import 'package:africaonlinestores/features/social/data/social_repository_impl.dart';
import 'package:africaonlinestores/features/social/domain/social_friends_page.dart';

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
