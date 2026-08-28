import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/call_runtime_log.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_action_handler.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_params_mapper.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

/// Coordinates the native call surface for flutter_callkit_incoming 3.1.5.
///
/// Backend call IDs and native CallKit UUIDs intentionally remain separate.
class CallKitService {
  final CallKitActionHandler actionHandler;
  final CallKitParamsMapper paramsMapper;
  final CallKitPendingPayloadStore pendingPayloadStore;
  final Future<void> Function(bool isActive)? onAudioSessionChanged;

  StreamSubscription<CallEvent?>? _sub;
  String? _currentCallId;
  bool _initialized = false;

  final Set<String> _shownIncomingCallIds = <String>{};
  final Set<String> _connectedCallIds = <String>{};
  final Set<String> _endedCallIds = <String>{};
  final Set<String> _handledAcceptIds = <String>{};
  final Set<String> _handledDeclineIds = <String>{};
  final Set<String> _handledEndIds = <String>{};
  final Set<String> _handledTimeoutIds = <String>{};
  final Map<String, String> _callkitUuidByCallId = <String, String>{};
  final Map<String, String> _callIdByCallkitUuid = <String, String>{};

  CallKitService({
    required this.actionHandler,
    required this.paramsMapper,
    this.pendingPayloadStore = const CallKitPendingPayloadStore(),
    this.onAudioSessionChanged,
  });

  Future<void> init() async {
    if (_initialized) return;

    // Notification permission is owned by PushNotificationService. AOS does
    // not request Android full-screen-intent special access; incoming calls use
    // the native call notification surface and explicit user actions instead.
    await _hydratePendingCallkitMapping();

    await _sub?.cancel();
    _sub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);
    _initialized = true;

    CallRuntimeLog.write('callkit_service_initialized');
    appLogger.i('📞 CallKitService initialized');
  }

  Future<void> showIncomingCall({
    required String callId,
    required AOSCallType callType,
    CallParticipant? caller,
    String? roomName,
  }) async {
    final normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) {
      appLogger.e('❌ Cannot show CallKit incoming call: missing callId');
      return;
    }

    if (_shownIncomingCallIds.contains(normalizedCallId) ||
        _endedCallIds.contains(normalizedCallId)) {
      return;
    }

    final callkitUuid = _getOrCreateCallkitUuid(normalizedCallId);
    final params = paramsMapper.incoming(
      callkitUuid: callkitUuid,
      callId: normalizedCallId,
      callType: callType,
      caller: caller,
      roomName: roomName,
    );

    _shownIncomingCallIds.add(normalizedCallId);
    _currentCallId = normalizedCallId;

    try {
      await pendingPayloadStore.save(
        asJsonMap(
          params.extra ??
              <String, dynamic>{
                'call_id': normalizedCallId,
                'callkit_uuid': callkitUuid,
              },
        ),
      );
      appLogger.i(
        '📞 Pending CallKit mapping persisted (callId=$normalizedCallId)',
      );
    } catch (error, stackTrace) {
      // Persistence supports recovery, but must never block the live incoming
      // call surface while the app is already running.
      appLogger.w(
        '📞 Could not persist CallKit mapping; showing incoming UI anyway '
        '(callId=$normalizedCallId)',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await _showIncoming(params, backendCallId: normalizedCallId);
  }

  Future<void> _showIncoming(
    CallKitParams params, {
    required String backendCallId,
  }) async {
    final callkitUuid = params.id.trim();

    try {
      CallRuntimeLog.write('callkit_show_requested', callId: backendCallId);
      await FlutterCallkitIncoming.showCallkitIncoming(params);
      CallRuntimeLog.write('callkit_show_completed', callId: backendCallId);
      appLogger.i(
        '📞 CallKit incoming call shown: $callkitUuid for backend call $backendCallId',
      );
    } catch (error, stackTrace) {
      _shownIncomingCallIds.remove(backendCallId);
      if (callkitUuid.isNotEmpty) {
        _callkitUuidByCallId.remove(backendCallId);
        _callIdByCallkitUuid.remove(callkitUuid);
      }
      await pendingPayloadStore.clearIfMatches(backendCallId);
      CallRuntimeLog.write(
        'callkit_show_failed',
        callId: backendCallId,
        details: const <String, Object?>{'failure': 'native_error'},
      );
      appLogger.e(
        '❌ Failed to show CallKit incoming call',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String?> registerOutgoingCall({
    required String callId,
    required AOSCallType callType,
    CallParticipant? receiver,
  }) async {
    final normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty) return null;
    if (_endedCallIds.contains(normalizedCallId)) {
      return _callkitUuidByCallId[normalizedCallId];
    }

    final callkitUuid = _getOrCreateCallkitUuid(normalizedCallId);
    final params = paramsMapper.outgoing(
      callkitUuid: callkitUuid,
      callId: normalizedCallId,
      callType: callType,
      receiver: receiver,
    );
    _currentCallId = normalizedCallId;

    try {
      CallRuntimeLog.write(
        'callkit_outgoing_start_requested',
        callId: normalizedCallId,
      );
      await FlutterCallkitIncoming.startCall(params);
      CallRuntimeLog.write(
        'callkit_outgoing_start_completed',
        callId: normalizedCallId,
      );
      return callkitUuid;
    } catch (error, stackTrace) {
      _callkitUuidByCallId.remove(normalizedCallId);
      _callIdByCallkitUuid.remove(callkitUuid);
      if (_currentCallId == normalizedCallId) _currentCallId = null;
      CallRuntimeLog.write(
        'callkit_outgoing_start_failed',
        callId: normalizedCallId,
        details: const <String, Object?>{'failure': 'native_error'},
      );
      appLogger.e(
        '❌ Failed to start outgoing CallKit call',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> setCallConnected(String callId) async {
    final normalizedCallId = callId.trim();
    if (normalizedCallId.isEmpty || !_connectedCallIds.add(normalizedCallId)) {
      return;
    }

    final callkitUuid = _callkitUuidByCallId[normalizedCallId];
    if (callkitUuid == null || callkitUuid.isEmpty) {
      _connectedCallIds.remove(normalizedCallId);
      return;
    }

    try {
      await FlutterCallkitIncoming.setCallConnected(callkitUuid);
      CallRuntimeLog.write('callkit_connected', callId: normalizedCallId);
    } catch (error, stackTrace) {
      _connectedCallIds.remove(normalizedCallId);
      CallRuntimeLog.write(
        'callkit_connected_failed',
        callId: normalizedCallId,
        details: const <String, Object?>{'failure': 'native_error'},
      );
      appLogger.w(
        '⚠️ Failed to mark CallKit call connected: $normalizedCallId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> endCall({String? callId}) async {
    final id = (callId ?? _currentCallId)?.trim();
    if (id == null || id.isEmpty || !_endedCallIds.add(id)) return;

    final callkitUuid = _callkitUuidByCallId[id];
    try {
      if (callkitUuid != null && callkitUuid.isNotEmpty) {
        await FlutterCallkitIncoming.endCall(callkitUuid);
      }
      _clearActiveCallGuards(id);
      _callkitUuidByCallId.remove(id);
      if (callkitUuid != null) _callIdByCallkitUuid.remove(callkitUuid);
      await pendingPayloadStore.clearIfMatches(id);
      await pendingPayloadStore.clearActionIfMatches(id);
      if (_currentCallId == id) _currentCallId = null;
      CallRuntimeLog.write('callkit_ended', callId: id);
    } catch (error, stackTrace) {
      _endedCallIds.remove(id);
      appLogger.w(
        '⚠️ Failed to end CallKit call: $id',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> endAllCalls() async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
      _currentCallId = null;
      _shownIncomingCallIds.clear();
      _connectedCallIds.clear();
      _endedCallIds.clear();
      _handledAcceptIds.clear();
      _handledDeclineIds.clear();
      _handledEndIds.clear();
      _handledTimeoutIds.clear();
      _callkitUuidByCallId.clear();
      _callIdByCallkitUuid.clear();
      await pendingPayloadStore.clear();
      await pendingPayloadStore.clearAction();
      CallRuntimeLog.write('callkit_all_ended');
    } catch (error, stackTrace) {
      appLogger.w(
        '⚠️ Failed to end all CallKit calls',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _hydratePendingCallkitMapping() async {
    try {
      final payload = await pendingPayloadStore.read();
      if (payload == null) return;

      final callId = _readString(payload, const <String>[
        'call_id',
        'backend_call_id',
        'backendCallId',
        'aos_call_id',
        'id',
      ]);
      final callkitUuid = _readString(payload, const <String>[
        'callkit_uuid',
        'callkit_id',
        'uuid',
      ]);
      if (callId == null || callId.isEmpty) return;

      _currentCallId ??= callId;
      _shownIncomingCallIds.add(callId);
      if (callkitUuid != null && callkitUuid.isNotEmpty) {
        _callkitUuidByCallId[callId] = callkitUuid;
        _callIdByCallkitUuid[callkitUuid] = callId;
      }
    } catch (error, stackTrace) {
      appLogger.w(
        '⚠️ Failed to hydrate pending CallKit mapping',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleEvent(CallEvent? event) async {
    if (event == null) return;

    final eventName = event.eventName;
    if (event case CallEventActionCallToggleAudioSession(:final isActive)) {
      appLogger.i('📞 CallKit audio-session event (active=$isActive)');
      final callback = onAudioSessionChanged;
      if (callback != null) {
        try {
          await callback(isActive);
        } catch (error, stackTrace) {
          appLogger.w(
            '📞 Failed to synchronize CallKit/LiveKit audio session',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      return;
    }

    await _hydratePendingCallkitMapping();
    final params = _paramsForLifecycleEvent(event);
    final extractedCallId = params == null ? null : _extractCallId(params);
    if (extractedCallId != null && extractedCallId.isNotEmpty) {
      _currentCallId = extractedCallId;
    }

    final callId = _currentCallId;
    appLogger.i(
      '📞 CallKit event received '
      '(event=$eventName, callId=${callId ?? 'none'})',
    );
    CallRuntimeLog.write(
      'callkit_event',
      callId: callId,
      details: <String, Object?>{'name': eventName},
    );

    if (callId == null || callId.isEmpty || _endedCallIds.contains(callId)) {
      appLogger.i(
        '📞 CallKit event ignored because no actionable backend call mapping exists '
        '(event=$eventName, callId=${callId ?? 'none'})',
      );
      return;
    }

    if (event is CallEventActionCallAccept) {
      await _handleAccept(callId);
      return;
    }
    if (event is CallEventActionCallDecline) {
      await _handleDecline(callId);
      return;
    }
    if (event is CallEventActionCallEnded) {
      await _handleEnded(callId);
      return;
    }
    if (event is CallEventActionCallTimeout) {
      await _handleTimeout(callId);
      return;
    }

    appLogger.i(
      '📞 CallKit event has no AOS lifecycle action '
      '(event=$eventName, callId=$callId)',
    );
  }

  CallKitParams? _paramsForLifecycleEvent(CallEvent event) {
    return switch (event) {
      CallEventActionCallAccept(:final callKitParams) => callKitParams,
      CallEventActionCallDecline(:final callKitParams) => callKitParams,
      CallEventActionCallEnded(:final callKitParams) => callKitParams,
      _ => null,
    };
  }

  Future<void> _handleAccept(String callId) async {
    if (_handledDeclineIds.contains(callId) ||
        _handledTimeoutIds.contains(callId) ||
        _handledEndIds.contains(callId) ||
        !_handledAcceptIds.add(callId)) {
      return;
    }

    final resolved = await _executeLifecycleAction(
      callId: callId,
      action: PendingCallKitAction.accept,
      execute: () => actionHandler.onAccept(callId: callId),
    );
    if (!resolved) _handledAcceptIds.remove(callId);
  }

  Future<void> _handleDecline(String callId) async {
    if (_handledAcceptIds.contains(callId) ||
        _handledEndIds.contains(callId) ||
        !_handledDeclineIds.add(callId)) {
      return;
    }

    final resolved = await _executeLifecycleAction(
      callId: callId,
      action: PendingCallKitAction.decline,
      execute: () => actionHandler.onDecline(callId: callId),
    );
    if (!resolved) _handledDeclineIds.remove(callId);
  }

  Future<void> _handleEnded(String callId) async {
    if (!_handledEndIds.add(callId)) return;

    final resolved = await _executeLifecycleAction(
      callId: callId,
      action: PendingCallKitAction.ended,
      execute: () => actionHandler.onEnded(callId: callId),
    );
    if (!resolved) _handledEndIds.remove(callId);
  }

  Future<void> _handleTimeout(String callId) async {
    if (_handledAcceptIds.contains(callId) ||
        _handledDeclineIds.contains(callId) ||
        _handledEndIds.contains(callId) ||
        !_handledTimeoutIds.add(callId)) {
      return;
    }

    final resolved = await _executeLifecycleAction(
      callId: callId,
      action: PendingCallKitAction.timeout,
      execute: () => actionHandler.onTimeout(callId: callId),
    );
    if (!resolved) _handledTimeoutIds.remove(callId);
  }

  Future<bool> _executeLifecycleAction({
    required String callId,
    required PendingCallKitAction action,
    required Future<bool> Function() execute,
  }) async {
    await pendingPayloadStore.saveAction(
      callId: callId,
      action: action,
      callkitUuid: _callkitUuidByCallId[callId],
    );

    try {
      final resolved = await execute();
      if (!resolved) return false;

      await pendingPayloadStore.markActionHandled(
        callId: callId,
        action: action,
      );
      await pendingPayloadStore.clearActionIfMatches(callId);
      await pendingPayloadStore.clearIfMatches(callId);
      return true;
    } catch (error, stackTrace) {
      appLogger.w(
        '📞 CallKit lifecycle action remains pending for recovery '
        '(callId=$callId, action=${action.name})',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  String? _extractCallId(CallKitParams params) {
    final extra = params.extra ?? const <String, dynamic>{};
    final backendCallId = _readString(extra, const <String>[
      'call_id',
      'backend_call_id',
      'backendCallId',
      'aos_call_id',
    ]);

    final rawNativeId = _clean(params.id);
    if (backendCallId != null) {
      if (rawNativeId != null) {
        _callkitUuidByCallId[backendCallId] = rawNativeId;
        _callIdByCallkitUuid[rawNativeId] = backendCallId;
      }
      return backendCallId;
    }

    if (rawNativeId == null) return null;
    return _callIdByCallkitUuid[rawNativeId] ??
        (rawNativeId.startsWith('CALL-') ? rawNativeId : null);
  }

  String _getOrCreateCallkitUuid(String callId) {
    final existing = _callkitUuidByCallId[callId];
    if (existing != null && existing.isNotEmpty) return existing;

    final uuid = const Uuid().v4();
    _callkitUuidByCallId[callId] = uuid;
    _callIdByCallkitUuid[uuid] = callId;
    return uuid;
  }

  String? _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = _clean(source[key]);
      if (value != null) return value;
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

  void _clearActiveCallGuards(String callId) {
    _shownIncomingCallIds.remove(callId);
    _connectedCallIds.remove(callId);
    _handledAcceptIds.remove(callId);
    _handledDeclineIds.remove(callId);
    _handledEndIds.remove(callId);
    _handledTimeoutIds.remove(callId);
  }

  void dispose() {
    unawaited(_sub?.cancel());
    _sub = null;
    _initialized = false;
  }
}
