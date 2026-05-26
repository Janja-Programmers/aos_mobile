import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/social/presentation/screens/profile_screen.dart';

class SocialRoutes {
  const SocialRoutes._();

  static List<RouteBase> routes() {
    return [
      GoRoute(
        name: AppRoutes.nProfile,
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ];
  }
}

class SocialNavigation {
  const SocialNavigation._();

  static void toProfileScreen(BuildContext context, {required String user}) {
    final cleanUser = user.trim();

    if (cleanUser.isEmpty) return;

    context.pushNamed(
      AppRoutes.nProfile,
      // pathParameters: {'user': Uri.encodeComponent(cleanUser)},
    );
  }
}
