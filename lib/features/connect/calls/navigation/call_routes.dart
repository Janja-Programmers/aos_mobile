import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_list_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_session_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/new_call_screen.dart';

class CallRoutes {
  const CallRoutes._();

  static List<GoRoute> routes() => [
    // 📞 CALL LIST (like ChatList)
    GoRoute(
      name: AppRoutes.nCallsList,
      path: AppRoutes.callsList,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'];
        return CallListScreen(searchQuery: searchQuery);
      },
    ),

    // ➕ NEW CALL (select contact)
    GoRoute(
      name: AppRoutes.nNewCall,
      path: AppRoutes.newCall,
      builder: (context, state) {
        return const NewCallScreen();
      },
    ),

    // 🎯 CALL SESSION (handles ringing + active internally)
    GoRoute(
      name: AppRoutes.nCallSession,
      path: AppRoutes.callSession,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};

        return MaterialPage(
          key: const ValueKey('call_session'),
          child: CallSessionScreen(
            user: extra['user'] ?? '',
            displayName: extra['displayName'] ?? '',
            isVideo: extra['isVideo'] ?? false,
          ),
        );
      },
    ),
  ];
}

class CallNavigation {
  const CallNavigation._();

  static void toCallsList(BuildContext context, {String? search}) {
    context.pushNamed(
      AppRoutes.nCallsList,
      queryParameters: (search != null && search.isNotEmpty)
          ? {'search': search}
          : {},
    );
  }

  static void toNewCall(BuildContext context) {
    context.pushNamed(AppRoutes.nNewCall);
  }

  static void startCall({
    required BuildContext context,
    required String user,
    required String displayName,
    bool isVideo = false,
  }) {
    final router = GoRouter.of(context);

    final targetLocation = router.namedLocation(AppRoutes.nCallSession);

    final currentLocation = GoRouterState.of(context).uri.toString();

    // 🚫 Prevent stacking multiple call screens
    if (currentLocation == targetLocation) return;

    if (router.routerDelegate.currentConfiguration.fullPath !=
        AppRoutes.callSession) {
      router.goNamed(
        AppRoutes.nCallSession,
        extra: {'user': user, 'displayName': displayName, 'isVideo': isVideo},
      );
    }
  }
}
