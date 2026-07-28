import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';

/// Persists native actions using flutter_callkit_incoming 3.0.0's event model.
///
/// Version 3.0.0 exposes one [CallEvent] with an [Event] enum and a map-like
/// `body`. The sealed `CallEventActionCall*` classes belong to 3.1.x and must
/// not be referenced while the dependency is pinned to 3.0.0.
@pragma('vm:entry-point')
Future<void> callKitBackgroundMessageHandler(CallEvent event) async {
  const store = CallKitPendingPayloadStore();

  try {
    final resolved = await _resolveBackgroundAction(event, store);
    if (resolved == null) {
      return;
    }

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

Future<_ResolvedBackgroundAction?> _resolveBackgroundAction(
  CallEvent event,
  CallKitPendingPayloadStore store,
) async {
  final action = switch (event.event) {
    Event.actionCallAccept => PendingCallKitAction.accept,
    Event.actionCallDecline => PendingCallKitAction.decline,
    Event.actionCallEnded => PendingCallKitAction.ended,
    Event.actionCallTimeout => PendingCallKitAction.timeout,
    _ => null,
  };

  if (action == null) {
    return null;
  }

  final body = asJsonMap(event.body);
  final extra = asJsonMap(body['extra']);
  final pendingPayload = await store.read();

  final callId = _clean(
    extra['call_id'] ??
        extra['backend_call_id'] ??
        body['call_id'] ??
        body['backend_call_id'] ??
        pendingPayload?['call_id'] ??
        pendingPayload?['backend_call_id'],
  );
  if (callId == null) {
    return null;
  }

  final nativeId = _clean(body['id']);
  final callkitUuid = _clean(
    nativeId ??
        extra['callkit_uuid'] ??
        extra['callkit_id'] ??
        pendingPayload?['callkit_uuid'] ??
        pendingPayload?['callkit_id'],
  );

  return _ResolvedBackgroundAction(
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

class _ResolvedBackgroundAction {
  final String callId;
  final PendingCallKitAction action;
  final String? callkitUuid;

  const _ResolvedBackgroundAction({
    required this.callId,
    required this.action,
    required this.callkitUuid,
  });
}
