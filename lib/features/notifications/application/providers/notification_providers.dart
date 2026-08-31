import 'package:africaonlinestores/core/navigation/pending_protected_navigation_store.dart';
import 'package:africaonlinestores/core/navigation/protected_navigation_coordinator.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/app_lock/application/app_lock_controller.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/push_token_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/go_router_protected_navigation_executor.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_missed_call_action_coordinator.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_realtime_listener.dart';
import 'package:africaonlinestores/features/notifications/application/services/push_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/state/notification_state.dart';
import 'package:africaonlinestores/features/notifications/data/notification_api.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/data/push_token_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref.watch(apiClientProvider));
});

final pushTokenApiProvider = Provider<PushTokenApi>((ref) {
  return PushTokenApi(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(notificationApiProvider));
});

final pushTokenRepositoryProvider = Provider<PushTokenRepository>((ref) {
  return PushTokenRepositoryImpl(ref.watch(pushTokenApiProvider));
});

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      return NotificationController(ref.watch(notificationRepositoryProvider));
    });

final pushTokenControllerProvider =
    StateNotifierProvider<PushTokenController, AsyncValue<void>>((ref) {
      return PushTokenController(ref.watch(pushTokenRepositoryProvider));
    });

final pendingProtectedNavigationStoreProvider =
    StateNotifierProvider<
      PendingProtectedNavigationStore,
      PendingProtectedNavigation?
    >((ref) {
      return PendingProtectedNavigationStore();
    });

final protectedNavigationAccessPolicyProvider = Provider<bool Function()>((
  ref,
) {
  return () => ref.read(appLockAccessPermittedProvider);
});

final protectedNavigationExecutorProvider =
    Provider<ProtectedNavigationExecutor>((ref) {
      return GoRouterProtectedNavigationExecutor(
        router: ref.watch(appRouterProvider),
        liveManager: ref.read(liveManagerProvider.notifier),
        adsApi: ref.read(adsApiProvider),
      );
    });

final protectedNavigationCoordinatorProvider =
    Provider<ProtectedNavigationCoordinator>((ref) {
      final ProtectedNavigationCoordinator coordinator =
          ProtectedNavigationCoordinator(
            store: ref.read(pendingProtectedNavigationStoreProvider.notifier),
            executor: ref.watch(protectedNavigationExecutorProvider),
            accessPermitted: ref.watch(protectedNavigationAccessPolicyProvider),
          );

      coordinator.handleAuthState(ref.read(authControllerProvider));
      ref.listen<AuthState>(authControllerProvider, (
        AuthState? previous,
        AuthState next,
      ) {
        coordinator.handleAuthState(next);
      });
      return coordinator;
    });

final notificationMissedCallActionCoordinatorProvider =
    Provider<NotificationMissedCallActionCoordinator>((ref) {
      return NotificationMissedCallActionCoordinator(
        recoverCallLifecycle: (String? originalCallId) async {
          final callKit = ref.read(callKitServiceProvider);
          await ref.read(callKitRecoveryServiceProvider).recover();

          final String? callId = originalCallId?.trim();
          if (callId != null && callId.isNotEmpty) {
            await callKit.endCall(callId: callId);
          }
        },
        isCallLifecycleBusy: () {
          final CallState callState = ref.read(callManagerProvider);
          return callState.isBusy ||
              callState.isCallInProgress ||
              callState.hasIncomingCallUi ||
              callState.hasActiveRoom;
        },
      );
    });

final notificationNavigationHandlerProvider =
    Provider<NotificationNavigationHandler>((ref) {
      return NotificationNavigationHandler(
        coordinator: ref.watch(protectedNavigationCoordinatorProvider),
      );
    });

final notificationRealtimeListenerProvider =
    Provider<NotificationRealtimeListener>((ref) {
      final realtime = ref.watch(realtimeServiceProvider);
      final NotificationRealtimeListener listener =
          NotificationRealtimeListener(
            eventStream: realtime.events,
            connectionStream: realtime.connections,
            controller: ref.read(notificationControllerProvider.notifier),
          );
      listener.attach();
      ref.onDispose(listener.dispose);
      return listener;
    });

final inAppNotificationServiceProvider = Provider<InAppNotificationService>((
  ref,
) {
  final InAppNotificationService service = InAppNotificationService();
  ref.onDispose(service.dispose);
  return service;
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final PushNotificationService service = PushNotificationService(
    messaging: FirebaseMessaging.instance,
    controller: ref.read(notificationControllerProvider.notifier),
    navigationHandler: ref.read(notificationNavigationHandlerProvider),
    pushRepo: ref.read(pushTokenRepositoryProvider),
    bannerService: ref.read(inAppNotificationServiceProvider),
    incomingCallBootstrapper: ref.read(incomingCallBootstrapperProvider),
    callKitRecoveryService: ref.read(callKitRecoveryServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
