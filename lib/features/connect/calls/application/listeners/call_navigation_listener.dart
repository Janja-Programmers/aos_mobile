import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';

class CallNavigationListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallNavigationListener({super.key, required this.child});

  @override
  ConsumerState<CallNavigationListener> createState() =>
      _CallNavigationListenerState();
}

class _CallNavigationListenerState
    extends ConsumerState<CallNavigationListener> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(socketCallListenerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callManagerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation(context, state.status);
    });

    return widget.child;
  }

  void _handleNavigation(BuildContext context, CallStatus status) {
    if (_isNavigating) return;

    final router = ref.read(appRouterProvider);
    final currentLocation = router.routerDelegate.currentConfiguration.fullPath;

    String? targetRoute;

    switch (status) {
      case CallStatus.incoming:
        targetRoute = AppRoutes.incomingCall;
        break;

      case CallStatus.dialing:
      case CallStatus.ringing:
        targetRoute = AppRoutes.outgoingCall;
        break;

      case CallStatus.connected:
        targetRoute = AppRoutes.activeCall;
        break;

      case CallStatus.ended:
      case CallStatus.rejected:
      case CallStatus.failed:
        targetRoute = AppRoutes.calls;
        break;

      default:
        return;
    }

    if (currentLocation == targetRoute) return;

    _isNavigating = true;

    router.goNamed(_mapRouteName(status));

    Future.microtask(() {
      _isNavigating = false;
    });
  }

  String _mapRouteName(CallStatus status) {
    switch (status) {
      case CallStatus.incoming:
        return AppRoutes.nIncomingCall;

      case CallStatus.dialing:
      case CallStatus.ringing:
        return AppRoutes.nOutgoingCall;

      case CallStatus.connected:
        return AppRoutes.nActiveCall;

      case CallStatus.notAnswered:
      case CallStatus.rejected:
        return AppRoutes.nCallNotAnswered;

      case CallStatus.ended:
      case CallStatus.failed:
        return AppRoutes.nCalls;

      default:
        return AppRoutes.nCalls;
    }
  }
}
