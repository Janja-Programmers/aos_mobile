import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/incoming_call_bootstrapper.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/pending_callkit_action_replayer.dart';

/// Reconciles native CallKit state with the backend once the authenticated
/// Flutter runtime is available again.
///
/// Native actions are replayed before the pending incoming payload so an
/// Answer/Decline made while Dart was unavailable wins over merely restoring
/// the ringing state. Both paths re-query authoritative backend call status.
class CallKitRecoveryService {
  final PendingCallKitActionReplayer actionReplayer;
  final IncomingCallBootstrapper incomingCallBootstrapper;
  final CallKitPendingPayloadStore store;

  Future<void>? _inFlight;

  CallKitRecoveryService({
    required this.actionReplayer,
    required this.incomingCallBootstrapper,
    this.store = const CallKitPendingPayloadStore(),
  });

  Future<void> recover() {
    return _inFlight ??= _recover().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<void> _recover() async {
    final actionResult = await actionReplayer.replay();
    if (actionResult == PendingCallKitActionReplayResult.retryPending) {
      appLogger.i(
        '📞 Pending native call action has priority over ringing recovery; '
        'deferring incoming payload restoration',
      );
      return;
    }

    try {
      final payload = await store.read();
      if (payload == null || payload.isEmpty) {
        appLogger.i('📞 No pending CallKit payload to recover');
        return;
      }

      final callId = _clean(payload['call_id']) ?? _clean(payload['id']);
      appLogger.i(
        '📞 Recovering pending CallKit payload '
        '(callId=${callId ?? 'none'})',
      );

      final handled = await incomingCallBootstrapper.handlePushPayload(payload);
      if (!handled) {
        appLogger.i(
          '📞 Pending CallKit payload is no longer actionable; clearing it',
        );
        await store.clear();
        return;
      }

      appLogger.i('📞 Pending CallKit payload recovery completed');
    } catch (error, stackTrace) {
      appLogger.w(
        '⚠️ Pending CallKit payload recovery failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
