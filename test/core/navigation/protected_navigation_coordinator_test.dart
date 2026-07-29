import 'package:africaonlinestores/core/navigation/pending_protected_navigation_store.dart';
import 'package:africaonlinestores/core/navigation/protected_navigation_coordinator.dart';
import 'package:africaonlinestores/core/navigation/protected_navigation_destination.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ProtectedNavigationDestination firstDestination =
      ProtectedNavigationDestination(
        kind: ProtectedNavigationKind.adDetails,
        canonicalId: 'AD-0001',
      );
  const ProtectedNavigationDestination secondDestination =
      ProtectedNavigationDestination(
        kind: ProtectedNavigationKind.profile,
        canonicalId: 'user@example.invalid',
      );

  AuthAuthenticated authenticated(String email) {
    return AuthAuthenticated(
      user: AuthUser(email: email, fullName: 'Test User'),
      sid: 'session-for-$email',
    );
  }

  test('authenticated request executes exactly once', () {
    final PendingProtectedNavigationStore store =
        PendingProtectedNavigationStore();
    final _RecordingExecutor executor = _RecordingExecutor();
    final ProtectedNavigationCoordinator coordinator =
        ProtectedNavigationCoordinator(
          store: store,
          executor: executor,
          accessPermitted: () => true,
        );
    coordinator.handleAuthState(authenticated('user@example.invalid'));

    expect(
      coordinator.submit(
        sourceKey: 'notification-1',
        destination: firstDestination,
      ),
      isTrue,
    );
    expect(
      coordinator.submit(
        sourceKey: 'notification-1',
        destination: firstDestination,
      ),
      isFalse,
    );

    expect(executor.destinations, <ProtectedNavigationDestination>[
      firstDestination,
    ]);
    expect(store.state, isNull);
  });

  test('one pending destination is superseded before access is permitted', () {
    bool accessPermitted = false;
    final PendingProtectedNavigationStore store =
        PendingProtectedNavigationStore();
    final _RecordingExecutor executor = _RecordingExecutor();
    final ProtectedNavigationCoordinator coordinator =
        ProtectedNavigationCoordinator(
          store: store,
          executor: executor,
          accessPermitted: () => accessPermitted,
        );
    coordinator.handleAuthState(authenticated('user@example.invalid'));

    coordinator.submit(
      sourceKey: 'notification-1',
      destination: firstDestination,
    );
    coordinator.submit(
      sourceKey: 'notification-2',
      destination: secondDestination,
    );

    expect(store.state?.destination, secondDestination);
    expect(executor.destinations, isEmpty);

    accessPermitted = true;
    coordinator.resumePending();

    expect(executor.destinations, <ProtectedNavigationDestination>[
      secondDestination,
    ]);
    expect(store.state, isNull);
  });

  test('logout clears pending and deduplication state', () {
    bool accessPermitted = false;
    final PendingProtectedNavigationStore store =
        PendingProtectedNavigationStore();
    final _RecordingExecutor executor = _RecordingExecutor();
    final ProtectedNavigationCoordinator coordinator =
        ProtectedNavigationCoordinator(
          store: store,
          executor: executor,
          accessPermitted: () => accessPermitted,
        );
    coordinator.handleAuthState(authenticated('user@example.invalid'));
    coordinator.submit(
      sourceKey: 'notification-1',
      destination: firstDestination,
    );

    coordinator.handleAuthState(const AuthGuest());
    accessPermitted = true;
    coordinator.resumePending();

    expect(store.state, isNull);
    expect(executor.destinations, isEmpty);
  });

  test('account switch clears the previous account destination', () {
    bool accessPermitted = false;
    final PendingProtectedNavigationStore store =
        PendingProtectedNavigationStore();
    final _RecordingExecutor executor = _RecordingExecutor();
    final ProtectedNavigationCoordinator coordinator =
        ProtectedNavigationCoordinator(
          store: store,
          executor: executor,
          accessPermitted: () => accessPermitted,
        );
    coordinator.handleAuthState(authenticated('first@example.invalid'));
    coordinator.submit(
      sourceKey: 'notification-1',
      destination: firstDestination,
    );

    coordinator.handleAuthState(authenticated('second@example.invalid'));
    accessPermitted = true;
    coordinator.resumePending();

    expect(store.state, isNull);
    expect(executor.destinations, isEmpty);
  });

  test('guest requests cannot create protected navigation', () {
    final PendingProtectedNavigationStore store =
        PendingProtectedNavigationStore();
    final _RecordingExecutor executor = _RecordingExecutor();
    final ProtectedNavigationCoordinator coordinator =
        ProtectedNavigationCoordinator(
          store: store,
          executor: executor,
          accessPermitted: () => true,
        );

    expect(
      coordinator.submit(
        sourceKey: 'notification-1',
        destination: firstDestination,
      ),
      isFalse,
    );
    expect(executor.destinations, isEmpty);
  });
}

class _RecordingExecutor implements ProtectedNavigationExecutor {
  final List<ProtectedNavigationDestination> destinations =
      <ProtectedNavigationDestination>[];

  @override
  void execute(ProtectedNavigationDestination destination) {
    destinations.add(destination);
  }
}
