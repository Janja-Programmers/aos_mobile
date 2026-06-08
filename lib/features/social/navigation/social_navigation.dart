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
          final displayName = state.uri.queryParameters['display_name'];
          final avatar = state.uri.queryParameters['avatar'];

          return ProfileScreen(
            user: user,
            fallbackDisplayName: displayName,
            fallbackAvatar: avatar,
          );
        },
      ),

      GoRoute(
        name: AppRoutes.nSocialConnections,
        path: AppRoutes.socialConnections,
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final title = state.uri.queryParameters['title'] ?? 'Connections';
          final user = state.uri.queryParameters['user'];

          final initialTab = switch (tab) {
            'following' => SocialConnectionsTab.following,
            'friends' => SocialConnectionsTab.friends,
            'followers' || _ => SocialConnectionsTab.followers,
          };

          return SocialConnectionsScreen(
            title: title,
            initialTab: initialTab,
            targetUser: user,
          );
        },
      ),
    ];
  }
}

class SocialNavigation {
  const SocialNavigation._();

  static void toProfileScreen(
    BuildContext context, {
    required String user,
    String? displayName,
    String? avatar,
  }) {
    final cleanUser = user.trim();

    if (cleanUser.isEmpty) return;

    context.pushNamed(
      AppRoutes.nProfile,
      queryParameters: {
        'user': cleanUser,
        if (displayName?.trim().isNotEmpty == true)
          'display_name': displayName!.trim(),
        if (avatar?.trim().isNotEmpty == true) 'avatar': avatar!.trim(),
      },
    );
  }

  static void toSocialConnectionsScreen(
    BuildContext context, {
    SocialConnectionsTab tab = SocialConnectionsTab.followers,
    String? title,
    String? user,
  }) {
    context.pushNamed(
      AppRoutes.nSocialConnections,
      queryParameters: {
        'tab': _tabToQuery(tab),
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
        if (user != null && user.trim().isNotEmpty) 'user': user.trim(),
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
