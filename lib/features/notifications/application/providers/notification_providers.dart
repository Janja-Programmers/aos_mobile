import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/core/routing/app_router.dart';

import 'package:africaonlinestores/features/notifications/application/controllers/notification_controller.dart';
import 'package:africaonlinestores/features/notifications/application/controllers/push_token_controller.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_navigation_handler.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_realtime_listener.dart';
import 'package:africaonlinestores/features/notifications/application/services/push_notification_service.dart';
import 'package:africaonlinestores/features/notifications/application/state/notification_state.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/data/notification_api.dart';
import 'package:africaonlinestores/features/notifications/data/push_token_api.dart';

import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';

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
// NAVIGATION HANDLER
// =====================================================

final notificationNavigationHandlerProvider =
    Provider<NotificationNavigationHandler>((ref) {
      final router = ref.watch(appRouterProvider);
      final liveManager = ref.read(liveManagerProvider.notifier);

      return NotificationNavigationHandler(
        router: router,
        liveManager: liveManager,
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

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final messaging = FirebaseMessaging.instance;
  final controller = ref.read(notificationControllerProvider.notifier);
  final navigationHandler = ref.read(notificationNavigationHandlerProvider);
  final pushRepo = ref.read(pushTokenRepositoryProvider);

  final service = PushNotificationService(
    messaging: messaging,
    controller: controller,
    navigationHandler: navigationHandler,
    pushRepo: pushRepo,
  );

  // ⚠️ DO NOT auto-init here blindly
  // Let app bootstrap control lifecycle

  ref.onDispose(service.dispose);

  return service;
});

final inAppNotificationServiceProvider = Provider<InAppNotificationService>((
  ref,
) {
  final service = InAppNotificationService();

  ref.onDispose(service.dispose);

  return service;
});
