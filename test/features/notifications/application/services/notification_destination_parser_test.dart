import 'package:africaonlinestores/core/navigation/protected_navigation_destination.dart';
import 'package:africaonlinestores/features/notifications/application/services/notification_destination_parser.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_payload.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const NotificationDestinationParser parser = NotificationDestinationParser();

  test('uses canonical ad ID for an ad notification', () {
    final ProtectedNavigationDestination? destination = parser.parse(
      type: NotificationType.adApproved,
      payload: const NotificationPayload(adId: 'AD-2026-00001'),
    );

    expect(destination?.kind, ProtectedNavigationKind.adDetails);
    expect(destination?.canonicalId, 'AD-2026-00001');
  });

  test(
    'rejects malformed canonical IDs and uses the safe feature fallback',
    () {
      final ProtectedNavigationDestination? destination = parser.parse(
        type: NotificationType.adRejected,
        payload: const NotificationPayload(adId: '../account/delete'),
      );

      expect(destination?.kind, ProtectedNavigationKind.myAds);
      expect(destination?.canonicalId, isNull);
    },
  );

  test('accepts only allowlisted unknown internal routes', () {
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

  test('does not extract a short ID from an external route', () {
    final ProtectedNavigationDestination? destination = parser.parse(
      type: NotificationType.newShort,
      payload: const NotificationPayload(
        route: 'https://example.invalid/shorts/detail?short_id=SHORT-0001',
      ),
    );

    expect(destination?.kind, ProtectedNavigationKind.feeds);
    expect(destination?.canonicalId, isNull);
  });

  test('parses an allowlisted ad detail route with a validated ID', () {
    final ProtectedNavigationDestination? destination = parser.parse(
      type: NotificationType.unknown,
      payload: const NotificationPayload(route: '/ads/detail/AD-0002'),
    );

    expect(destination?.kind, ProtectedNavigationKind.adDetails);
    expect(destination?.canonicalId, 'AD-0002');
  });

  test('incoming-call navigation remains owned by the call pipeline', () {
    final ProtectedNavigationDestination? destination = parser.parse(
      type: NotificationType.incomingCall,
      payload: const NotificationPayload(callId: 'CALL-0001'),
    );

    expect(destination, isNull);
  });
}
