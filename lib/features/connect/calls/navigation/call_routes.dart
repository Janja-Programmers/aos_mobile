import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_list_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/call_session_screen.dart';
import 'package:africaonlinestores/features/connect/calls/presentation/screens/new_call_screen.dart';

class CallRoutes {
  const CallRoutes._();

  static List<GoRoute> routes() => [
    /// 📞 CALL LIST
    GoRoute(
      name: AppRoutes.nCallsList,
      path: AppRoutes.callsList,
      builder: (context, state) {
        final searchQuery = state.uri.queryParameters['search'];
        return CallListScreen(searchQuery: searchQuery);
      },
    ),

    /// ➕ NEW CALL
    GoRoute(
      name: AppRoutes.nNewCall,
      path: AppRoutes.newCall,
      builder: (context, state) {
        return const NewCallScreen();
      },
    ),

    /// 🎯 CALL SESSION (STATE-DRIVEN, NOT EXTRA-DRIVEN)
    GoRoute(
      name: AppRoutes.nCallSession,
      path: AppRoutes.callSession,
      pageBuilder: (context, state) {
        return MaterialPage(
          key: UniqueKey(),
          child: const CallSessionScreen(
            user: '',
            displayName: '',
            isVideo: false,
          ),
        );
      },
    ),
  ];
}

class CallNavigation {
  const CallNavigation._();

  /// 📞 CALL LIST
  static void toCallsList(WidgetRef ref, {String? search}) {
    final router = ref.read(appRouterProvider);

    router.pushNamed(
      AppRoutes.nCallsList,
      queryParameters: (search != null && search.isNotEmpty)
          ? {'search': search}
          : {},
    );
  }

  /// ➕ NEW CALL
  static void toNewCall(WidgetRef ref) {
    final router = ref.read(appRouterProvider);

    router.pushNamed(AppRoutes.nNewCall);
  }

  /// 🔥 RETURN TO ACTIVE CALL (OVERLAY TAP)
  static void toActiveCall(WidgetRef ref) {
    final router = ref.read(appRouterProvider);

    final config = router.routerDelegate.currentConfiguration;

    final isOnCall = config.fullPath == AppRoutes.callSession;

    if (!isOnCall) {
      router.pushNamed(AppRoutes.nCallSession);
    }
  }

  /// 🚀 START NEW CALL (OUTGOING)
  static void startCall({
    required WidgetRef ref,
    required String user,
    required String displayName,
    bool isVideo = false,
  }) {
    final router = ref.read(appRouterProvider);

    final config = router.routerDelegate.currentConfiguration;

    final isOnCall = config.uri.toString().contains(AppRoutes.callSession);

    /// 🚫 prevent stacking multiple call screens
    if (isOnCall) return;

    router.pushNamed(
      AppRoutes.nCallSession,
      extra: {'user': user, 'displayName': displayName, 'isVideo': isVideo},
    );
  }
}
