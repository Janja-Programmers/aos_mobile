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
  UiCallPhase? _lastHandledPhase;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // ✅ LISTEN SAFELY HERE
    ref.listenManual<CallState>(callManagerProvider, (previous, next) {
      _onStateChanged(previous?.uiPhase, next.uiPhase);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onStateChanged(UiCallPhase? prev, UiCallPhase next) {
    if (_lastHandledPhase == next) return;
    _lastHandledPhase = next;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleNavigation(prev, next);
    });
  }

  void _handleNavigation(UiCallPhase? prev, UiCallPhase next) {
    if (_isNavigating) return;

    final router = ref.read(appRouterProvider);
    final currentLocation = router.routerDelegate.currentConfiguration.fullPath;

    final isInCallSession = currentLocation == AppRoutes.callSession;

    final enteringCall = !_wasInCallSession(prev) && _isInCallSession(next);

    if (enteringCall && !isInCallSession) {
      _isNavigating = true;
      router.goNamed(AppRoutes.nCallSession);
      _releaseLock();
      return;
    }

    // exit handled elsewhere
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
        return false;
    }
  }

  bool _wasInCallSession(UiCallPhase? phase) {
    if (phase == null) return false;
    return _isInCallSession(phase);
  }

  void _releaseLock() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _isNavigating = false;
    });
  }
}
