import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_action_handler.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';

enum PendingCallKitActionReplayResult { none, handled, retryPending, discarded }

typedef PendingCallKitActionExecutor =
    Future<bool> Function({
      required PendingCallKitAction action,
      required String callId,
    });

class PendingCallKitActionReplayer {
  static const Duration pendingActionMaxAge = Duration(minutes: 5);

  final PendingCallKitActionExecutor actionExecutor;
  final CallKitPendingPayloadStore store;
  final DateTime Function() now;

  PendingCallKitActionReplayer({
    CallKitActionHandler? actionHandler,
    PendingCallKitActionExecutor? actionExecutor,
    this.store = const CallKitPendingPayloadStore(),
    DateTime Function()? now,
    // ignore: prefer_asserts_with_message
  }) : assert(actionHandler != null || actionExecutor != null),
       actionExecutor = actionExecutor ?? actionHandler!.handlePendingAction,
       now = now ?? DateTime.now;

  Future<PendingCallKitActionReplayResult> replay() async {
    final payload = await store.readAction();
    if (payload == null || payload.isEmpty) {
      return PendingCallKitActionReplayResult.none;
    }

    final callId = _clean(payload['call_id']);
    final action = _parseAction(payload['action']);
    final createdAt = _parseCreatedAt(payload['created_at_ms']);

    if (callId == null || action == null || createdAt == null) {
      await store.clearAction();
      return PendingCallKitActionReplayResult.discarded;
    }

    if (_isExpired(createdAt)) {
      appLogger.i(
        '📞 Discarding expired pending CallKit action '
        '(callId=$callId, action=${action.name})',
      );
      await store.clearActionIfMatches(callId);
      await store.clearIfMatches(callId);
      return PendingCallKitActionReplayResult.discarded;
    }

    if (await store.wasActionHandled(callId: callId, action: action)) {
      await store.clearActionIfMatches(callId);
      await store.clearIfMatches(callId);
      return PendingCallKitActionReplayResult.handled;
    }

    appLogger.i(
      '📞 Replaying pending CallKit action '
      '(callId=$callId, action=${action.name})',
    );

    try {
      final resolved = await actionExecutor(action: action, callId: callId);
      if (!resolved) {
        appLogger.w(
          '📞 Pending CallKit action remains unresolved; retaining for retry '
          '(callId=$callId, action=${action.name})',
        );
        return PendingCallKitActionReplayResult.retryPending;
      }
    } catch (error, stackTrace) {
      appLogger.w(
        '📞 Pending CallKit action replay failed; retaining for retry '
        '(callId=$callId, action=${action.name})',
        error: error,
        stackTrace: stackTrace,
      );
      return PendingCallKitActionReplayResult.retryPending;
    }

    await store.markActionHandled(callId: callId, action: action);
    await store.clearActionIfMatches(callId);
    await store.clearIfMatches(callId);
    return PendingCallKitActionReplayResult.handled;
  }

  bool _isExpired(DateTime createdAt) {
    final age = now().difference(createdAt);
    return age >= pendingActionMaxAge;
  }

  DateTime? _parseCreatedAt(Object? value) {
    final milliseconds = switch (value) {
      final int number => number,
      final String text => int.tryParse(text.trim()),
      _ => null,
    };
    if (milliseconds == null || milliseconds <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  PendingCallKitAction? _parseAction(Object? value) {
    final normalized = _clean(value)?.toLowerCase();
    if (normalized == null) return null;
    for (final action in PendingCallKitAction.values) {
      if (action.name == normalized) return action;
    }
    return null;
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
