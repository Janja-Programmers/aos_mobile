import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_params_mapper.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_action_handler.dart';

class CallKitService {
  final CallKitActionHandler actionHandler;
  final CallKitParamsMapper paramsMapper;

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

  CallKitService({required this.actionHandler, required this.paramsMapper});

  // -----------------------------
  // Lifecycle
  // -----------------------------
  Future<void> init() async {
    if (_initialized) return;

    await ensurePermissions();

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

      if (callkitUuid != null && callkitUuid.isNotEmpty) {
        _callkitUuidByCallId.remove(backendCallId);
        _callIdByCallkitUuid.remove(callkitUuid);
      }

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

      appLogger.i('📴 All CallKit calls ended');
    } catch (e, s) {
      appLogger.w(
        '⚠️ Failed to end all CallKit calls',
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

    final extractedCallId = _extractCallId(event);
    _currentCallId = extractedCallId ?? _currentCallId;

    final resolvedCallId = _currentCallId;

    appLogger.i('📞 CallKit event: ${event.event}');
    appLogger.i('📞 CallKit resolved callId: $resolvedCallId');

    if (resolvedCallId == null || resolvedCallId.isEmpty) {
      appLogger.w('⚠️ Ignoring CallKit event with no callId');
      return;
    }

    switch (event.event) {
      case Event.actionCallAccept:
        await _handleAccept(resolvedCallId);
        break;

      case Event.actionCallDecline:
        await _handleDecline(resolvedCallId);
        break;

      case Event.actionCallEnded:
        await _handleEnded(resolvedCallId);
        break;

      case Event.actionCallTimeout:
        await _handleTimeout(resolvedCallId);
        break;

      default:
        break;
    }
  }

  Future<void> _handleAccept(String callId) async {
    if (!_handledAcceptIds.add(callId)) {
      appLogger.i('📞 Duplicate CallKit accept ignored: $callId');
      return;
    }

    await actionHandler.onAccept(callId: callId);
  }

  Future<void> _handleDecline(String callId) async {
    if (!_handledDeclineIds.add(callId)) {
      appLogger.i('📞 Duplicate CallKit decline ignored: $callId');
      return;
    }

    await actionHandler.onDecline(callId: callId);
  }

  Future<void> _handleEnded(String callId) async {
    if (!_handledEndIds.add(callId)) {
      appLogger.i('📞 Duplicate CallKit end ignored: $callId');
      return;
    }

    await actionHandler.onEnded(callId: callId);
  }

  Future<void> _handleTimeout(String callId) async {
    if (!_handledTimeoutIds.add(callId)) {
      appLogger.i('📞 Duplicate CallKit timeout ignored: $callId');
      return;
    }

    await actionHandler.onTimeout(callId: callId);
  }

  String? _extractCallId(CallEvent event) {
    final body = event.body;

    if (body is! Map) return null;

    final extra = body['extra'];

    if (extra is Map && extra['call_id'] != null) {
      return extra['call_id'].toString();
    }

    final rawId = body['id']?.toString();

    if (rawId == null || rawId.isEmpty) {
      return null;
    }

    // If native event gives CallKit UUID, map it back to backend call id.
    final mappedCallId = _callIdByCallkitUuid[rawId];
    if (mappedCallId != null && mappedCallId.isNotEmpty) {
      return mappedCallId;
    }

    // Last fallback: only return rawId if it looks like your backend call id.
    if (rawId.startsWith('CALL-')) {
      return rawId;
    }

    appLogger.w(
      '⚠️ Could not resolve CallKit event id to backend callId: $rawId',
    );
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

    // Keep _endedCallIds intact.
    // This prevents stale duplicate events from reviving a native call.
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _initialized = false;
  }
}
