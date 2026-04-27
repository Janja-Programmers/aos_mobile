import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

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

  late final ProviderSubscription<CallState> _sub;

  @override
  void initState() {
    super.initState();

    _sub = ref.listenManual<CallState>(callManagerProvider, (previous, next) {
      _onStateChanged(previous?.uiPhase, next.uiPhase);
    });
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(callManagerProvider);

    return widget.child;
  }

  void _onStateChanged(UiCallPhase? prev, UiCallPhase next) {
    if (prev == next) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleNavigation(prev, next);
    });
  }

  void _handleNavigation(UiCallPhase? prev, UiCallPhase next) {
    if (_isNavigating) return;

    final router = ref.read(appRouterProvider);

    final location = router.routerDelegate.currentConfiguration.uri.toString();

    final isInCallSession = location.contains(AppRoutes.callSession);

    /// 🔥 ENTER CALL
    final enteringCall =
        prev != null && !_isInCallSession(prev) && _isInCallSession(next);

    if (enteringCall && !isInCallSession) {
      _isNavigating = true;

      router.pushNamed(AppRoutes.nCallSession);

      _releaseLock();
      return;
    }

    /// 🔥 EXIT CALL (FIXED FINAL)
    final isExitTransition =
        prev != null && _isInCallSession(prev) && !_isInCallSession(next);

    if (isExitTransition) {
      _isNavigating = true;

      router.goNamed(AppRoutes.nConnect, queryParameters: {'tab': 'calls'});

      _releaseLock();
    }
  }

  bool _isInCallSession(UiCallPhase phase) {
    switch (phase) {
      case UiCallPhase.incomingRinging:
      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
        return true;

      case UiCallPhase.idle:
      case UiCallPhase.finished:
      case UiCallPhase.error:
      case UiCallPhase.cancelled:
        return false;
    }
  }

  void _releaseLock() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _isNavigating = false;
    });
  }
}
