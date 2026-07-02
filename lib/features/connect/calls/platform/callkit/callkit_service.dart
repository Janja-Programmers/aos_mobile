import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_action_handler.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_params_mapper.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_pending_payload_store.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

class CallKitService {
  final CallKitActionHandler actionHandler;
  final CallKitParamsMapper paramsMapper;
  final CallKitPendingPayloadStore pendingPayloadStore;

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
  });

  // -----------------------------
  // Lifecycle
  // -----------------------------
  Future<void> init() async {
    if (_initialized) return;

    await ensurePermissions();
    await _hydratePendingCallkitMapping();

    await _sub?.cancel();
    _sub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);

    _initialized = true;

    appLogger.i('📞 CallKitService initialized');
  }

  Future<void> ensurePermissions() async {
    try {
      await FlutterCallkitIncoming.requestFullIntentPermission();

      await FlutterCallkitIncoming.requestNotificationPermission({
        'title': 'Notification permission',
        'rationaleMessagePermission':
            'We need permission to show incoming calls',
        'postNotificationMessageRequired':
            'Please enable notifications in settings to receive calls',
      });
    } catch (e, s) {
      appLogger.w(
        '⚠️ CallKit permission request failed or unavailable',
        error: e,
        stackTrace: s,
      );
    }
  }

  // -----------------------------
  // Incoming call
  // -----------------------------
  Future<void> showIncomingCall({
    required String callId,
    required AOSCallType callType,
    CallParticipant? caller,
    String? roomName,
  }) async {
    if (callId.trim().isEmpty) {
      appLogger.e('❌ Cannot show CallKit incoming call: missing callId');
      return;
    }

    if (_shownIncomingCallIds.contains(callId)) {
      appLogger.i('📞 CallKit incoming already shown: $callId');
      return;
    }

    if (_endedCallIds.contains(callId)) {
      appLogger.i(
        '📞 Ignoring CallKit incoming for already ended call: $callId',
      );
      return;
    }

    final callkitUuid = _getOrCreateCallkitUuid(callId);

    _shownIncomingCallIds.add(callId);
    _currentCallId = callId;

    final params = paramsMapper.incoming(
      callkitUuid: callkitUuid,
      callId: callId,
      callType: callType,
      caller: caller,
      roomName: roomName,
    );

    await pendingPayloadStore.save(
      asJsonMap(
        params.extra ??
            <String, dynamic>{'call_id': callId, 'callkit_uuid': callkitUuid},
      ),
    );

    await _showIncoming(params, backendCallId: callId);
  }

  Future<void> _showIncoming(
    CallKitParams params, {
    required String backendCallId,
  }) async {
    final callkitUuid = params.id;

    try {
      await FlutterCallkitIncoming.showCallkitIncoming(params);

      appLogger.i(
        '📞 CallKit incoming call shown: $callkitUuid for backend call $backendCallId',
      );
    } catch (e, s) {
      _shownIncomingCallIds.remove(backendCallId);

      if (callkitUuid.isNotEmpty) {
        _callkitUuidByCallId.remove(backendCallId);
        _callIdByCallkitUuid.remove(callkitUuid);
      }

      await pendingPayloadStore.clearIfMatches(backendCallId);

      appLogger.e(
        '❌ Failed to show CallKit incoming call',
        error: e,
        stackTrace: s,
      );
    }
  }

  // -----------------------------
  // Outgoing call
  // -----------------------------
  Future<String?> registerOutgoingCall({required String callId}) async {
    final normalizedCallId = callId.trim();

    if (normalizedCallId.isEmpty) {
      appLogger.e('❌ Cannot register outgoing CallKit call: missing callId');
      return null;
    }

    if (_endedCallIds.contains(normalizedCallId)) {
      appLogger.i(
        '📞 Ignoring outgoing CallKit registration for already ended call: $normalizedCallId',
      );
      return _callkitUuidByCallId[normalizedCallId];
    }

    final callkitUuid = _getOrCreateCallkitUuid(normalizedCallId);

    _currentCallId = normalizedCallId;

    appLogger.i(
      '📞 Outgoing CallKit UUID registered: $callkitUuid for backend call $normalizedCallId',
    );

    return callkitUuid;
  }

  // -----------------------------
  // Connected / ended sync
  // -----------------------------
  Future<void> setCallConnected(String callId) async {
    if (callId.trim().isEmpty) return;

    if (_connectedCallIds.contains(callId)) {
      return;
    }

    final callkitUuid = _callkitUuidByCallId[callId];

    if (callkitUuid == null || callkitUuid.isEmpty) {
      appLogger.w(
        '⚠️ Cannot mark CallKit call connected: missing CallKit UUID for $callId',
      );
      return;
    }

    _connectedCallIds.add(callId);

    try {
      await FlutterCallkitIncoming.setCallConnected(callkitUuid);

      appLogger.i(
        '📞 CallKit native call connected: $callkitUuid for backend call $callId',
      );
    } catch (e, s) {
      _connectedCallIds.remove(callId);

      appLogger.w(
        '⚠️ Failed to mark CallKit call connected: $callId',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> endCall({String? callId}) async {
    final id = callId ?? _currentCallId;
    if (id == null || id.isEmpty) return;

    if (_endedCallIds.contains(id)) {
      appLogger.i('📴 CallKit call already ended: $id');
      return;
    }

    final callkitUuid = _callkitUuidByCallId[id];

    if (callkitUuid == null || callkitUuid.isEmpty) {
      appLogger.i('📴 No CallKit UUID found for ended call: $id');

      _endedCallIds.add(id);
      _clearActiveCallGuards(id);
      await pendingPayloadStore.clearIfMatches(id);

      if (_currentCallId == id) {
        _currentCallId = null;
      }

      return;
    }

    _endedCallIds.add(id);

    try {
      await FlutterCallkitIncoming.endCall(callkitUuid);

      _clearActiveCallGuards(id);

      _callkitUuidByCallId.remove(id);
      _callIdByCallkitUuid.remove(callkitUuid);
      await pendingPayloadStore.clearIfMatches(id);

      if (_currentCallId == id) {
        _currentCallId = null;
      }

      appLogger.i(
        '📴 CallKit native call ended: $callkitUuid for backend call $id',
      );
    } catch (e, s) {
      appLogger.w(
        '⚠️ Failed to end CallKit call: $id',
        error: e,
        stackTrace: s,
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

      appLogger.i('📴 All CallKit calls ended');
    } catch (e, s) {
      appLogger.w(
        '⚠️ Failed to end all CallKit calls',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _hydratePendingCallkitMapping() async {
    try {
      final payload = await pendingPayloadStore.read();
      if (payload == null) return;

      final callId = _readString(payload, const [
        'call_id',
        'backend_call_id',
        'backendCallId',
        'aos_call_id',
        'id',
      ]);

      final callkitUuid = _readString(payload, const [
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
    } catch (e, s) {
      appLogger.w(
        '⚠️ Failed to hydrate pending CallKit mapping',
        error: e,
        stackTrace: s,
      );
    }
  }

  // -----------------------------
  // Native CallKit events
  // -----------------------------
  Future<void> _handleEvent(CallEvent? event) async {
    if (event == null) return;

    await _hydratePendingCallkitMapping();

    final extractedCallId = _extractCallId(event);
    if (extractedCallId != null && extractedCallId.isNotEmpty) {
      _currentCallId = extractedCallId;
    }

    final resolvedCallId = _currentCallId;

    appLogger.i('📞 CallKit event: ${_eventName(event)}');
    appLogger.i('📞 CallKit resolved callId: $resolvedCallId');

    if (resolvedCallId == null || resolvedCallId.isEmpty) {
      appLogger.w('⚠️ Ignoring CallKit event with no callId');
      return;
    }

    if (_endedCallIds.contains(resolvedCallId)) {
      return;
    }

    switch (event) {
      case CallEventActionCallAccept():
        await _handleAccept(resolvedCallId);
        break;

      case CallEventActionCallDecline():
        await _handleDecline(resolvedCallId);
        break;

      case CallEventActionCallEnded():
        await _handleEnded(resolvedCallId);
        break;

      case CallEventActionCallTimeout():
        await _handleTimeout(resolvedCallId);
        break;

      case CallEventActionCallIncoming():
        appLogger.i('📞 Incoming CallKit event received');
        break;

      case CallEventActionCallStart():
        appLogger.i('📞 Outgoing CallKit event started');
        break;

      case CallEventActionCallConnected():
        appLogger.i('📞 CallKit call connected');
        break;

      case CallEventActionCallCallback():
        appLogger.i('📞 CallKit callback requested');
        break;

      case CallEventActionCallToggleHold():
      case CallEventActionCallToggleMute():
      case CallEventActionCallToggleDmtf():
      case CallEventActionCallToggleGroup():
      case CallEventActionCallToggleAudioSession():
      case CallEventActionDidUpdateDevicePushTokenVoip():
      case CallEventActionCallCustom():
        break;
    }
  }

  Future<void> _handleAccept(String callId) async {
    if (_handledDeclineIds.contains(callId) ||
        _handledTimeoutIds.contains(callId) ||
        _handledEndIds.contains(callId)) {
      return;
    }

    if (!_handledAcceptIds.add(callId)) {
      appLogger.i('📞 Duplicate CallKit accept ignored: $callId');
      return;
    }

    await actionHandler.onAccept(callId: callId);
  }

  Future<void> _handleDecline(String callId) async {
    if (_handledAcceptIds.contains(callId) || _handledEndIds.contains(callId)) {
      return;
    }

    if (!_handledDeclineIds.add(callId)) {
      appLogger.i('📞 Duplicate CallKit decline ignored: $callId');
      return;
    }

    await actionHandler.onDecline(callId: callId);
  }

  Future<void> _handleEnded(String callId) async {
    if (!_handledEndIds.add(callId)) {
      return;
    }

    await actionHandler.onEnded(callId: callId);
  }

  Future<void> _handleTimeout(String callId) async {
    if (_handledAcceptIds.contains(callId) ||
        _handledDeclineIds.contains(callId) ||
        _handledEndIds.contains(callId)) {
      return;
    }

    if (!_handledTimeoutIds.add(callId)) {
      appLogger.i('📞 Duplicate CallKit timeout ignored: $callId');
      return;
    }

    await actionHandler.onTimeout(callId: callId);
  }

  String? _extractCallId(CallEvent event) {
    final callKitObject = _readCallKitObject(event);
    final bodyObject = _readBodyObject(event);

    final candidates = <Object?>[callKitObject, bodyObject, event];

    for (final candidate in candidates) {
      final backendCallId = _extractBackendCallIdFromCandidate(candidate);
      if (backendCallId == null || backendCallId.isEmpty) continue;

      final rawNativeId = _readRawId(candidate) ?? _readRawId(callKitObject);
      final callkitUuid = rawNativeId?.toString().trim();

      if (callkitUuid != null && callkitUuid.isNotEmpty) {
        _callkitUuidByCallId[backendCallId] = callkitUuid;
        _callIdByCallkitUuid[callkitUuid] = backendCallId;
      }

      return backendCallId;
    }

    for (final candidate in candidates) {
      final rawId = _readRawId(candidate)?.toString().trim();
      if (rawId == null || rawId.isEmpty || rawId.toLowerCase() == 'null') {
        continue;
      }

      final mappedCallId = _callIdByCallkitUuid[rawId];

      if (mappedCallId != null && mappedCallId.isNotEmpty) {
        return mappedCallId;
      }

      if (rawId.startsWith('CALL-')) {
        return rawId;
      }

      appLogger.w(
        '⚠️ Could not resolve CallKit event ID to backend callId: $rawId',
      );
    }

    return null;
  }

  String _eventName(CallEvent event) {
    final value = event.eventName.trim();
    if (value.isEmpty) {
      return event.runtimeType.toString();
    }
    return value.contains('.') ? value.split('.').last : value;
  }

  Object? _readCallKitObject(CallEvent event) {
    final body = _readBodyObject(event);
    if (body is Map) {
      final data = asJsonMap(body);
      return data['callKit'] ?? data['callKitParams'] ?? body;
    }
    return body;
  }

  Object? _readBodyObject(CallEvent event) {
    return switch (event) {
      CallEventActionCallIncoming(:final callKitParams) =>
        callKitParams.toJson(),
      CallEventActionCallStart(:final callKitParams) => callKitParams.toJson(),
      CallEventActionCallAccept(:final callKitParams) => callKitParams.toJson(),
      CallEventActionCallDecline(:final callKitParams) =>
        callKitParams.toJson(),
      CallEventActionCallEnded(:final callKitParams) => callKitParams.toJson(),
      CallEventActionCallTimeout(:final id) => <String, dynamic>{'id': id},
      CallEventActionCallConnected(:final id) => <String, dynamic>{'id': id},
      CallEventActionCallCallback(:final id) => <String, dynamic>{'id': id},
      CallEventActionCallToggleHold(:final id) => <String, dynamic>{'id': id},
      CallEventActionCallToggleMute(:final id) => <String, dynamic>{'id': id},
      CallEventActionCallToggleDmtf(:final id) => <String, dynamic>{'id': id},
      CallEventActionCallToggleGroup(:final id) => <String, dynamic>{'id': id},
      CallEventActionCallCustom(:final body) => asJsonMap(body),
      CallEventActionCallToggleAudioSession() ||
      CallEventActionDidUpdateDevicePushTokenVoip() => null,
    };
  }

  String? _extractBackendCallIdFromCandidate(Object? candidate) {
    final direct = _readString(candidate, const [
      'call_id',
      'backend_call_id',
      'backendCallId',
      'aos_call_id',
    ]);

    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final extra = _readExtra(candidate);
    return _readString(extra, const [
      'call_id',
      'backend_call_id',
      'backendCallId',
      'aos_call_id',
    ]);
  }

  Object? _readExtra(Object? source) {
    if (source == null) return null;

    if (source is Map) {
      final data = asJsonMap(source);
      return data['extra'] ?? data['extras'] ?? source;
    }

    return null;
  }

  Object? _readRawId(Object? source) {
    if (source == null) return null;

    if (source is Map) {
      final data = asJsonMap(source);
      return data['id'] ??
          data['uuid'] ??
          data['callkit_uuid'] ??
          data['callkit_id'] ??
          data['call_id'];
    }

    return null;
  }

  String? _readString(Object? source, List<String> keys) {
    if (source is! Map) return null;

    for (final key in keys) {
      final value = source[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value.toLowerCase() != 'null') {
        return value;
      }
    }

    return null;
  }

  // CALLKIT Helpers
  String _getOrCreateCallkitUuid(String callId) {
    final existing = _callkitUuidByCallId[callId];
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final uuid = const Uuid().v4();

    _callkitUuidByCallId[callId] = uuid;
    _callIdByCallkitUuid[uuid] = callId;

    return uuid;
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
