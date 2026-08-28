import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/call_presentation_policy.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallNavigationListener extends ConsumerStatefulWidget {
  final Widget child;

  const CallNavigationListener({super.key, required this.child});

  @override
  ConsumerState<CallNavigationListener> createState() =>
      _CallNavigationListenerState();
}

class _CallNavigationListenerState
    extends ConsumerState<CallNavigationListener> {
  late final ProviderSubscription<CallState> _callSub;
  late final ProviderSubscription<AppLifecycleSnapshot> _lifecycleSub;

  bool _reconcileScheduled = false;
  bool _shouldBeOnCallSession = false;

  @override
  void initState() {
    super.initState();

    _shouldBeOnCallSession = _computeShouldBeOnCallSession();

    _callSub = ref.listenManual<CallState>(callManagerProvider, (_, _) {
      _scheduleReconcile();
    });
    _lifecycleSub = ref.listenManual<AppLifecycleSnapshot>(
      appLifecycleControllerProvider,
      (_, _) => _scheduleReconcile(),
    );
  }

  @override
  void dispose() {
    _callSub.close();
    _lifecycleSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _scheduleReconcile() {
    if (_reconcileScheduled) return;
    _reconcileScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reconcileScheduled = false;
      if (!mounted) return;
      _reconcileNavigation();
    });
  }

  void _reconcileNavigation() {
    final shouldBeOnCallSession = _computeShouldBeOnCallSession();
    if (shouldBeOnCallSession == _shouldBeOnCallSession) return;

    final wasOnCallSession = _shouldBeOnCallSession;
    _shouldBeOnCallSession = shouldBeOnCallSession;

    final router = ref.read(appRouterProvider);
    if (shouldBeOnCallSession) {
      router.pushNamed(AppRoutes.nCallSession);
      return;
    }

    if (wasOnCallSession) {
      router.goNamed(AppRoutes.nConnect, queryParameters: {'tab': 'calls'});
    }
  }

  bool _computeShouldBeOnCallSession() {
    final state = ref.read(callManagerProvider);
    final lifecycle = ref.read(appLifecycleControllerProvider);
    return _shouldUseAosCallSession(state, lifecycle: lifecycle);
  }

  bool _shouldUseAosCallSession(
    CallState state, {
    required AppLifecycleSnapshot lifecycle,
  }) {
    if (state.isOutgoingNoAnswer) return true;

    switch (state.uiPhase) {
      case UiCallPhase.incomingRinging:
        return incomingCallSurfaceFor(
              isAndroid:
                  !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
              isAppVisible: lifecycle.isVisible,
            ) ==
            IncomingCallSurface.flutter;

      case UiCallPhase.outgoingStarting:
      case UiCallPhase.outgoingRinging:
      case UiCallPhase.joiningRoom:
      case UiCallPhase.inCall:
        return true;

      case UiCallPhase.idle:
      case UiCallPhase.finished:
      case UiCallPhase.cancelled:
      case UiCallPhase.error:
        return false;
    }
  }
}
