import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/social/presentation/screens/profile_screen.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:africaonlinestores/features/social/presentation/screens/social_connections_screen.dart';

class SocialRoutes {
  const SocialRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nProfile,
        path: AppRoutes.profile,
        builder: (context, state) {
          final user = state.uri.queryParameters['user'];

          return ProfileScreen(user: user);
        },
      ),

      GoRoute(
        name: AppRoutes.nSocialConnections,
        path: AppRoutes.socialConnections,
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final title = state.uri.queryParameters['title'] ?? 'Connections';

          final initialTab = switch (tab) {
            'following' => SocialConnectionsTab.following,
            'friends' => SocialConnectionsTab.friends,
            'followers' || _ => SocialConnectionsTab.followers,
          };

          return SocialConnectionsScreen(title: title, initialTab: initialTab);
        },
      ),
    ];
  }
}

class SocialNavigation {
  const SocialNavigation._();

  static void toProfileScreen(BuildContext context, {required String user}) {
    final cleanUser = user.trim();

    if (cleanUser.isEmpty) return;

    context.pushNamed(AppRoutes.nProfile, queryParameters: {'user': cleanUser});
  }

  static void toSocialConnectionsScreen(
    BuildContext context, {
    SocialConnectionsTab tab = SocialConnectionsTab.followers,
    String? title,
  }) {
    context.pushNamed(
      AppRoutes.nSocialConnections,
      queryParameters: {
        'tab': _tabToQuery(tab),
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      },
    );
  }

  static void toFollowersScreen(BuildContext context, {String? title}) {
    toSocialConnectionsScreen(
      context,
      tab: SocialConnectionsTab.followers,
      title: title,
    );
  }

  static void toFollowingScreen(BuildContext context, {String? title}) {
    toSocialConnectionsScreen(
      context,
      tab: SocialConnectionsTab.following,
      title: title,
    );
  }

  static void toFriendsScreen(BuildContext context, {String? title}) {
    toSocialConnectionsScreen(
      context,
      tab: SocialConnectionsTab.friends,
      title: title,
    );
  }

  static String _tabToQuery(SocialConnectionsTab tab) {
    switch (tab) {
      case SocialConnectionsTab.following:
        return 'following';
      case SocialConnectionsTab.followers:
        return 'followers';
      case SocialConnectionsTab.friends:
        return 'friends';
    }
  }
}
