import 'package:africaonlinestores/core/navigation/protected_navigation_destination.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_destination_parser.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const NotificationDestinationParser parser = NotificationDestinationParser();

  test(
    'approved ad uses public detail while rejected and expired use My Ads',
    () {
      final ProtectedNavigationDestination? approved = parser.parse(
        type: NotificationType.adApproved,
        payload: const NotificationPayload(adId: 'AD-2026-00001'),
      );
      final ProtectedNavigationDestination? rejected = parser.parse(
        type: NotificationType.adRejected,
        payload: const NotificationPayload(adId: 'AD-2026-00002'),
      );
      final ProtectedNavigationDestination? expired = parser.parse(
        type: NotificationType.adExpired,
        payload: const NotificationPayload(adId: 'AD-2026-00003'),
      );

      expect(approved?.kind, ProtectedNavigationKind.adDetails);
      expect(approved?.canonicalId, 'AD-2026-00001');
      expect(rejected?.kind, ProtectedNavigationKind.myAds);
      expect(rejected?.canonicalId, isNull);
      expect(expired?.kind, ProtectedNavigationKind.myAds);
      expect(expired?.canonicalId, isNull);
    },
  );

  test('review notifications use their canonical ad target', () {
    for (final NotificationType type in <NotificationType>[
      NotificationType.reviewReceived,
      NotificationType.reviewApproved,
      NotificationType.reviewRejected,
    ]) {
      final ProtectedNavigationDestination? destination = parser.parse(
        type: type,
        payload: const NotificationPayload(
          reviewId: 'REVIEW-1',
          adId: 'AD-2026-00004',
        ),
      );
      expect(destination?.kind, ProtectedNavigationKind.adDetails);
      expect(destination?.canonicalId, 'AD-2026-00004');
    }
  });

  test('malformed public ad ID uses safe Notification Center fallback', () {
    final ProtectedNavigationDestination? destination = parser.parse(
      type: NotificationType.adApproved,
      payload: const NotificationPayload(adId: '../account/delete'),
    );

    expect(destination?.kind, ProtectedNavigationKind.notifications);
    expect(destination?.canonicalId, isNull);
  });

  test('short mention uses Short detail like other Short activity', () {
    final ProtectedNavigationDestination? destination = parser.parse(
      type: NotificationType.shortMention,
      payload: const NotificationPayload(shortId: 'SHORT-0001'),
    );

    expect(destination?.kind, ProtectedNavigationKind.shortDetails);
    expect(destination?.canonicalId, 'SHORT-0001');
  });

  test('accepts only allowlisted internal routes', () {
    final ProtectedNavigationDestination? accepted = parser.parse(
      type: NotificationType.unknown,
      payload: const NotificationPayload(route: '/account'),
    );
    final ProtectedNavigationDestination? rejected = parser.parse(
      type: NotificationType.unknown,
      payload: const NotificationPayload(route: '/account/delete'),
    );

    expect(accepted?.kind, ProtectedNavigationKind.account);
    expect(rejected, isNull);
  });

  test('rejects external, protocol-relative, and traversal routes', () {
    const List<String> unsafeRoutes = <String>[
      'https://example.invalid/account',
      '//example.invalid/account',
      '/ads/../account',
      '/ads/%2E%2E/account',
      r'/ads/..\account',
    ];

    for (final String route in unsafeRoutes) {
      final ProtectedNavigationDestination? destination = parser.parse(
        type: NotificationType.unknown,
        payload: NotificationPayload(route: route),
      );
      expect(destination, isNull, reason: route);
    }
  });

  test('incoming-call navigation remains owned by the Calls pipeline', () {
    final ProtectedNavigationDestination? destination = parser.parse(
      type: NotificationType.incomingCall,
      payload: const NotificationPayload(callId: 'CALL-0001'),
    );

    expect(destination, isNull);
  });
}
