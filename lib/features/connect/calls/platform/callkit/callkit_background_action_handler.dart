import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';

/// Persists native actions delivered by flutter_callkit_incoming 3.1.5 while
/// the foreground Riverpod graph is unavailable.
@pragma('vm:entry-point')
Future<void> callKitBackgroundMessageHandler(CallEvent event) async {
  const store = CallKitPendingPayloadStore();

  try {
    final resolved = await resolveCallKitBackgroundAction(event, store);
    if (resolved == null) return;

    await store.saveAction(
      callId: resolved.callId,
      action: resolved.action,
      callkitUuid: resolved.callkitUuid,
    );
  } catch (error, stackTrace) {
    appLogger.e(
      'Background CallKit action persistence failed',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<ResolvedCallKitBackgroundAction?> resolveCallKitBackgroundAction(
  CallEvent event,
  CallKitPendingPayloadStore store,
) async {
  final (action, params) = switch (event) {
    CallEventActionCallAccept(:final callKitParams) => (
      PendingCallKitAction.accept,
      callKitParams,
    ),
    CallEventActionCallDecline(:final callKitParams) => (
      PendingCallKitAction.decline,
      callKitParams,
    ),
    CallEventActionCallEnded(:final callKitParams) => (
      PendingCallKitAction.ended,
      callKitParams,
    ),
    CallEventActionCallTimeout() => (PendingCallKitAction.timeout, null),
    _ => (null, null),
  };

  if (action == null || params == null) return null;

  final pendingPayload = await store.read();
  final callId = _clean(
    params.extra?['call_id'] ??
        params.extra?['backend_call_id'] ??
        pendingPayload?['call_id'] ??
        pendingPayload?['backend_call_id'],
  );
  if (callId == null) return null;

  final callkitUuid = _clean(
    params.id.isNotEmpty
        ? params.id
        : params.extra?['callkit_uuid'] ??
              params.extra?['callkit_id'] ??
              pendingPayload?['callkit_uuid'] ??
              pendingPayload?['callkit_id'],
  );

  return ResolvedCallKitBackgroundAction(
    callId: callId,
    action: action,
    callkitUuid: callkitUuid,
  );
}

String? _clean(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}

class ResolvedCallKitBackgroundAction {
  final String callId;
  final PendingCallKitAction action;
  final String? callkitUuid;

  const ResolvedCallKitBackgroundAction({
    required this.callId,
    required this.action,
    required this.callkitUuid,
  });
}
