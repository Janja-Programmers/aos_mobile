import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Notification Center uses backend categories instead of local filtering',
    () {
      final String screen = File(
        'lib/features/notifications/presentation/screens/notification_screen.dart',
      ).readAsStringSync();
      final String tabs = File(
        'lib/features/notifications/presentation/widgets/notification_tabs.dart',
      ).readAsStringSync();

      expect(screen, contains('controller.selectCategory(category)'));
      expect(screen, isNot(contains('filterNotifications(')));
      expect(tabs, contains('NotificationCategory.communication'));
      expect(tabs, contains('NotificationCategory.activity'));
      expect(tabs, contains('NotificationCategory.marketplace'));
      expect(tabs, contains('NotificationCategory.account'));
    },
  );

  test('Notification management exposes delete and clear but never hide', () {
    final Directory notificationDir = Directory('lib/features/notifications');
    final String source = notificationDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .map((File file) => file.readAsStringSync())
        .join('\n');

    expect(source, contains('deleteNotification'));
    expect(source, contains('clearCurrentCategory'));
    expect(source.toLowerCase(), isNot(contains('hide notification')));
    expect(source, isNot(contains('restoreNotification')));
    expect(source, isNot(contains("label: 'Undo'")));
  });

  test(
    'persistent realtime is canonical Notification Center version 1 only',
    () {
      final String listener = File(
        'lib/features/notifications/application/services/'
        'notification_realtime_listener.dart',
      ).readAsStringSync();
      final String realtimeEvent = File(
        'lib/core/realtime/realtime_event.dart',
      ).readAsStringSync();

      expect(listener, contains("'aos_notification_center'"));
      expect(listener, contains('static const int _version = 1'));
      expect(listener, isNot(contains('RealtimeEventType.aosFollow')));
      expect(listener, isNot(contains("id: 'follow_")));
      expect(realtimeEvent, contains('eventName'));
    },
  );

  test('ad navigation is lifecycle-safe and preflights public ad detail', () {
    final String parser = File(
      'lib/features/notifications/application/services/'
      'notification_destination_parser.dart',
    ).readAsStringSync();
    final String executor = File(
      'lib/features/notifications/application/services/'
      'go_router_protected_navigation_executor.dart',
    ).readAsStringSync();

    expect(parser, contains('case NotificationType.adRejected:'));
    expect(parser, contains('case NotificationType.adExpired:'));
    expect(parser, contains('kind: ProtectedNavigationKind.myAds'));
    expect(executor, contains('_openAdDetailsIfAvailable'));
    expect(executor, contains('_adsApi.getAd(adId: adId)'));
    expect(executor, contains('_router.goNamed(AppRoutes.nMyAds)'));
    expect(executor, contains('_router.goNamed(AppRoutes.nNotification)'));
    expect(
      executor,
      isNot(contains('_router.pushNamed<void>(AppRoutes.nMyAds)')),
    );
  });

  test(
    'missed-call actions reconcile and reuse the existing Calls lifecycle',
    () {
      final String screen = File(
        'lib/features/notifications/presentation/screens/notification_screen.dart',
      ).readAsStringSync();
      final String providers = File(
        'lib/features/notifications/application/providers/'
        'notification_providers.dart',
      ).readAsStringSync();
      final String coordinator = File(
        'lib/features/notifications/application/services/'
        'notification_missed_call_action_coordinator.dart',
      ).readAsStringSync();
      final Directory notificationDir = Directory('lib/features/notifications');
      final String notificationSource = notificationDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
          .map((File file) => file.readAsStringSync())
          .join('\n');

      expect(
        screen,
        contains('notificationMissedCallActionCoordinatorProvider'),
      );
      expect(screen, contains('missedCallCallbackServiceProvider'));
      expect(providers, contains('callKitRecoveryServiceProvider'));
      expect(providers, contains('await callKit.endCall(callId: callId)'));
      expect(providers, contains('callManagerProvider'));
      expect(coordinator, contains('alreadyStarting'));
      expect(coordinator, contains('_recoverCallLifecycle'));
      expect(coordinator, contains('originalCallId'));
      expect(coordinator, contains('_isCallLifecycleBusy'));
      expect(
        notificationSource,
        isNot(contains('callManager.startOutgoingCall')),
      );
      expect(notificationSource, isNot(contains('registerOutgoingCall(')));
      expect(notificationSource, isNot(contains('initiateCall(')));
    },
  );

  test('clear serializes behind point mutations', () {
    final String controller = File(
      'lib/features/notifications/application/controllers/'
      'notification_controller.dart',
    ).readAsStringSync();

    expect(controller, contains('_activeMutations'));
    expect(controller, contains('_waitForMutationsToSettle'));
    expect(controller, contains('_clearInFlight'));
    expect(controller, contains('if (!_clearInFlight)'));
  });
}
