import 'dart:collection';

import 'package:africaonlinestores/core/navigation/pending_protected_navigation_store.dart';
import 'package:africaonlinestores/core/navigation/protected_navigation_destination.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';

abstract interface class ProtectedNavigationExecutor {
  void execute(ProtectedNavigationDestination destination);
}

class ProtectedNavigationCoordinator {
  ProtectedNavigationCoordinator({
    required PendingProtectedNavigationStore store,
    required ProtectedNavigationExecutor executor,
    required bool Function() accessPermitted,
  }) : _store = store,
       _executor = executor,
       _accessPermitted = accessPermitted;

  final PendingProtectedNavigationStore _store;
  final ProtectedNavigationExecutor _executor;
  final bool Function() _accessPermitted;

  final Queue<String> _handledOrder = Queue<String>();
  final Set<String> _handledKeys = <String>{};

  String? _accountId;
  bool _isExecuting = false;

  static const int _handledCapacity = 64;

  void handleAuthState(AuthState authState) {
    final String? nextAccountId = authState is AuthAuthenticated
        ? authState.user.email.trim().toLowerCase()
        : null;

    if (nextAccountId == _accountId) return;

    _accountId = nextAccountId;
    clear();
  }

  bool submit({
    required String sourceKey,
    required ProtectedNavigationDestination destination,
  }) {
    final String? accountId = _accountId;
    if (accountId == null || accountId.isEmpty) return false;

    final String requestKey = '$accountId|$sourceKey|${destination.signature}';
    if (_handledKeys.contains(requestKey)) return false;

    _rememberHandled(requestKey);
    _store.replace(
      PendingProtectedNavigation(
        accountId: accountId,
        requestKey: requestKey,
        destination: destination,
      ),
    );
    resumePending();
    return true;
  }

  void resumePending() {
    if (_isExecuting || !_accessPermitted()) return;

    final PendingProtectedNavigation? request = _store.pending;
    if (request == null) return;

    if (request.accountId != _accountId) {
      _store.clear();
      return;
    }

    _isExecuting = true;
    _store.clear();
    try {
      _executor.execute(request.destination);
    } catch (error, stackTrace) {
      appLogger.e(
        'Protected navigation execution failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isExecuting = false;
    }
  }

  void clear() {
    _store.clear();
    _handledOrder.clear();
    _handledKeys.clear();
    _isExecuting = false;
  }

  void _rememberHandled(String requestKey) {
    _handledKeys.add(requestKey);
    _handledOrder.addLast(requestKey);

    while (_handledOrder.length > _handledCapacity) {
      final String removed = _handledOrder.removeFirst();
      _handledKeys.remove(removed);
    }
  }
}
