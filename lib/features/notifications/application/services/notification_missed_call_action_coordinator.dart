import 'package:africaonlinestores/core/utils/logger.dart';

typedef NotificationCallLifecycleRecovery =
    Future<void> Function(String? originalCallId);
typedef NotificationCallLifecycleBusyReader = bool Function();
typedef NotificationMissedCallStarter = Future<bool> Function();

enum NotificationMissedCallActionOutcome {
  started,
  alreadyStarting,
  callInProgress,
  recoveryFailed,
  startFailed,
}

/// Notification-owned handoff into the existing Calls lifecycle.
///
/// This coordinator deliberately does not initiate calls, mutate CallManager,
/// register CallKit state, or navigate to a call screen. It only makes the
/// notification action safe before delegating to the existing Calls entry
/// point supplied by [NotificationMissedCallStarter].
class NotificationMissedCallActionCoordinator {
  NotificationMissedCallActionCoordinator({
    required NotificationCallLifecycleRecovery recoverCallLifecycle,
    required NotificationCallLifecycleBusyReader isCallLifecycleBusy,
  }) : _recoverCallLifecycle = recoverCallLifecycle,
       _isCallLifecycleBusy = isCallLifecycleBusy;

  final NotificationCallLifecycleRecovery _recoverCallLifecycle;
  final NotificationCallLifecycleBusyReader _isCallLifecycleBusy;

  Future<NotificationMissedCallActionOutcome>? _inFlight;

  Future<NotificationMissedCallActionOutcome> run({
    required NotificationMissedCallStarter start,
    String? originalCallId,
  }) {
    if (_inFlight != null) {
      return Future<NotificationMissedCallActionOutcome>.value(
        NotificationMissedCallActionOutcome.alreadyStarting,
      );
    }

    final Future<NotificationMissedCallActionOutcome> operation = _run(
      start,
      originalCallId,
    );
    _inFlight = operation;

    return operation.whenComplete(() {
      if (identical(_inFlight, operation)) {
        _inFlight = null;
      }
    });
  }

  Future<NotificationMissedCallActionOutcome> _run(
    NotificationMissedCallStarter start,
    String? originalCallId,
  ) async {
    try {
      await _recoverCallLifecycle(originalCallId);
    } catch (error, stackTrace) {
      appLogger.e(
        'Missed-call notification could not reconcile the existing call '
        'lifecycle',
        error: error,
        stackTrace: stackTrace,
      );
      return NotificationMissedCallActionOutcome.recoveryFailed;
    }

    if (_isCallLifecycleBusy()) {
      appLogger.i(
        'Missed-call notification callback ignored because another call '
        'lifecycle is active',
      );
      return NotificationMissedCallActionOutcome.callInProgress;
    }

    try {
      final bool started = await start();
      return started
          ? NotificationMissedCallActionOutcome.started
          : NotificationMissedCallActionOutcome.startFailed;
    } catch (error, stackTrace) {
      appLogger.e(
        'Missed-call notification delegation to Calls failed',
        error: error,
        stackTrace: stackTrace,
      );
      return NotificationMissedCallActionOutcome.startFailed;
    }
  }
}
