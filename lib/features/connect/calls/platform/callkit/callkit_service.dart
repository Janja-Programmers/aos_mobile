import 'dart:async';

import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_action_handler.dart';
import 'package:africaonlinestores/features/connect/calls/platform/callkit/callkit_params_mapper.dart';

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

    _shownIncomingCallIds.add(callId);
    _currentCallId = callId;

    final params = paramsMapper.incoming(
      callId: callId,
      callType: callType,
      caller: caller,
      roomName: roomName,
    );

    await _showIncoming(params);
  }

  Future<void> _showIncoming(CallKitParams params) async {
    final callId = params.id;

    try {
      await FlutterCallkitIncoming.showCallkitIncoming(params);
      appLogger.i('📞 CallKit incoming call shown: $callId');
    } catch (e, s) {
      if (callId != null && callId.isNotEmpty) {
        _shownIncomingCallIds.remove(callId);
      }

      appLogger.e(
        '❌ Failed to show CallKit incoming call',
        error: e,
        stackTrace: s,
      );
    }
  }

  // -----------------------------
  // Connected / ended sync
  // -----------------------------
  Future<void> setCallConnected(String callId) async {
    if (callId.trim().isEmpty) return;

    if (_connectedCallIds.contains(callId)) {
      return;
    }

    _connectedCallIds.add(callId);

    try {
      await FlutterCallkitIncoming.setCallConnected(callId);
      appLogger.i('📞 CallKit native call connected: $callId');
    } catch (e, s) {
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

    _endedCallIds.add(id);

    try {
      await FlutterCallkitIncoming.endCall(id);

      _clearActiveCallGuards(id);

      if (_currentCallId == id) {
        _currentCallId = null;
      }

      appLogger.i('📴 CallKit native call ended: $id');
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

    if (body['id'] != null) {
      return body['id'].toString();
    }

    return null;
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
