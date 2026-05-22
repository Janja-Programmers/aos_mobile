import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/repository/call_repository_impl.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/call_signaling_handler.dart';

class IncomingCallBootstrapper {
  final CallRepository repository;
  final CallSignalingHandler signalingHandler;

  const IncomingCallBootstrapper({
    required this.repository,
    required this.signalingHandler,
  });

  Future<bool> handlePushPayload(Map<String, dynamic> payload) async {
    try {
      if (!_isIncomingCallPayload(payload)) {
        return false;
      }

      final callId = _cleanString(payload['call_id']) ?? _cleanString(payload['id']);

      if (callId == null) {
        appLogger.w('📞 Incoming call push ignored: missing call_id');
        return false;
      }

      final status = await repository.getCallStatus(callId: callId);

      if (!_canShowIncomingUi(status)) {
        appLogger.i(
          '📞 Incoming call push ignored: stale call status=${status['status']} callId=$callId',
        );
        return true;
      }

      final mergedPayload = <String, dynamic>{
        ...payload,
        ...status,
        'event': 'aos_incoming_call',
        'type': 'incoming_call',
        'notification_type': 'incoming_call',
      };

      final handled = await signalingHandler.handleIncomingCall(mergedPayload);

      appLogger.i(
        '📞 Incoming call push bootstrap ${handled ? 'handled' : 'ignored'}: $callId',
      );

      return handled;
    } catch (e, s) {
      appLogger.e(
        '📞 Incoming call push bootstrap failed',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  bool _isIncomingCallPayload(Map<String, dynamic> payload) {
    final event = _cleanString(payload['event']);
    final type = _cleanString(payload['type']);
    final notificationType = _cleanString(payload['notification_type']);

    return event == 'aos_incoming_call' ||
        event == 'incoming_call' ||
        type == 'incoming_call' ||
        type == 'call' ||
        notificationType == 'incoming_call';
  }

  bool _canShowIncomingUi(Map<String, dynamic> status) {
    final explicit = status['can_show_incoming_ui'];
    if (explicit != null) {
      return _parseBool(explicit);
    }

    final isActive = _parseBool(status['is_active']);
    final callStatus = _cleanString(status['status']);

    return isActive && (callStatus == 'initiated' || callStatus == 'ringing');
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value?.toString().trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }

  String? _cleanString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}