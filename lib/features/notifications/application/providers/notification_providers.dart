import 'package:africaonlinestores/core/navigation/pending_protected_navigation_store.dart';
import 'package:africaonlinestores/core/navigation/protected_navigation_coordinator.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/routing/app_router.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/push_token_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/go_router_protected_navigation_executor.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
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
// =====================================================
// API
// =====================================================

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationApi(apiClient);
});

final pushTokenApiProvider = Provider<PushTokenApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PushTokenApi(apiClient);
});

// =====================================================
// REPOSITORY
// =====================================================

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.watch(notificationApiProvider);
  return NotificationRepositoryImpl(api);
});

final pushTokenRepositoryProvider = Provider<PushTokenRepository>((ref) {
  final api = ref.watch(pushTokenApiProvider);
  return PushTokenRepositoryImpl(api);
});

// =====================================================
// CONTROLLERS
// =====================================================

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      return NotificationController(repo);
    });

final pushTokenControllerProvider =
    StateNotifierProvider<PushTokenController, AsyncValue<void>>((ref) {
      final repo = ref.watch(pushTokenRepositoryProvider);
      return PushTokenController(repo);
    });

// =====================================================
// PROTECTED NAVIGATION FOUNDATION
// =====================================================

final pendingProtectedNavigationStoreProvider = StateNotifierProvider<
  PendingProtectedNavigationStore,
  PendingProtectedNavigation?
>((ref) {
  return PendingProtectedNavigationStore();
});

final protectedNavigationAccessPolicyProvider = Provider<bool Function()>((ref) {
  // Native app-lock will replace this policy in a later iteration.
  return () => true;
});

final protectedNavigationExecutorProvider =
    Provider<ProtectedNavigationExecutor>((ref) {
      return GoRouterProtectedNavigationExecutor(
        router: ref.watch(appRouterProvider),
        liveManager: ref.read(liveManagerProvider.notifier),
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
      ref.listen<AuthState>(authControllerProvider, (previous, next) {
        coordinator.handleAuthState(next);
      });

      return coordinator;
    });

// =====================================================
// NOTIFICATION NAVIGATION HANDLER
// =====================================================

final notificationNavigationHandlerProvider =
    Provider<NotificationNavigationHandler>((ref) {
      return NotificationNavigationHandler(
        coordinator: ref.watch(protectedNavigationCoordinatorProvider),
      );
    });

// =====================================================
// REALTIME LISTENER
// =====================================================

final notificationRealtimeListenerProvider =
    Provider<NotificationRealtimeListener>((ref) {
      final realtime = ref.watch(realtimeServiceProvider);
      final controller = ref.read(notificationControllerProvider.notifier);

      final listener = NotificationRealtimeListener(
        eventStream: realtime.events,
        controller: controller,
      );

      listener.attach();

      ref.onDispose(listener.dispose);

      return listener;
    });

// =====================================================
// PUSH SERVICE
// =====================================================

final inAppNotificationServiceProvider = Provider<InAppNotificationService>((
  ref,
) {
  final service = InAppNotificationService();
  ref.onDispose(service.dispose);
  return service;
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final messaging = FirebaseMessaging.instance;
  final controller = ref.read(notificationControllerProvider.notifier);
  final navigationHandler = ref.read(notificationNavigationHandlerProvider);
  final pushRepo = ref.read(pushTokenRepositoryProvider);
  final bannerService = ref.read(inAppNotificationServiceProvider);
  final incomingCallBootstrapper = ref.read(incomingCallBootstrapperProvider);

  final service = PushNotificationService(
    messaging: messaging,
    controller: controller,
    navigationHandler: navigationHandler,
    pushRepo: pushRepo,
    bannerService: bannerService,
    incomingCallBootstrapper: incomingCallBootstrapper,
  );

  ref.onDispose(service.dispose);

  return service;
});
