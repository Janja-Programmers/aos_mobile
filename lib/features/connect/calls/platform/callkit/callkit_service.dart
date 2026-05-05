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

  CallKitService({required this.actionHandler, required this.paramsMapper});

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await ensurePermissions();

    _sub?.cancel();
    _sub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);

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

    _currentCallId = callId;

    final params = paramsMapper.incoming(
      callId: callId,
      callType: callType,
      caller: caller,
      roomName: roomName,
    );

    await _showIncoming(params);
  }

  Future<void> endCall({String? callId}) async {
    final id = callId ?? _currentCallId;
    if (id == null || id.isEmpty) return;

    try {
      await FlutterCallkitIncoming.endCall(id);

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
    } catch (e, s) {
      appLogger.w(
        '⚠️ Failed to end all CallKit calls',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _showIncoming(CallKitParams params) async {
    try {
      await FlutterCallkitIncoming.showCallkitIncoming(params);
      appLogger.i('📞 CallKit incoming call shown: ${params.id}');
    } catch (e, s) {
      appLogger.e(
        '❌ Failed to show CallKit incoming call',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> _handleEvent(CallEvent? event) async {
    if (event == null) return;

    final callId = _extractCallId(event);
    _currentCallId = callId ?? _currentCallId;

    appLogger.i('📞 CallKit event: ${event.event}');
    appLogger.i('📞 CallKit resolved callId: $_currentCallId');

    switch (event.event) {
      case Event.actionCallAccept:
        await actionHandler.onAccept(callId: _currentCallId);
        break;

      case Event.actionCallDecline:
        await actionHandler.onDecline(callId: _currentCallId);
        await endCall(callId: _currentCallId);
        break;

      case Event.actionCallEnded:
        await actionHandler.onEnded(callId: _currentCallId);
        await endCall(callId: _currentCallId);
        break;

      case Event.actionCallTimeout:
        await actionHandler.onTimeout(callId: _currentCallId);
        await endCall(callId: _currentCallId);
        break;

      default:
        break;
    }
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

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _initialized = false;
  }
}
