import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

typedef CallStatusReader =
    Future<Map<String, dynamic>> Function({required String callId});

typedef OutgoingCallStarter =
    Future<bool> Function({
      required String userId,
      required AOSCallType callType,
      CallParticipant? receiver,
    });

/// Starts a new call from a persistent backend missed-call notification.
///
/// The backend notification carries the canonical caller account ID and call
/// ID. The original call type is resolved from `get_call_status` when
/// possible. Audio is the safe backend-supported fallback when that optional
/// lookup is unavailable.
class MissedCallCallbackService {
  const MissedCallCallbackService({
    required CallStatusReader readCallStatus,
    required OutgoingCallStarter startOutgoingCall,
  }) : _readCallStatus = readCallStatus,
       _startOutgoingCall = startOutgoingCall;

  final CallStatusReader _readCallStatus;
  final OutgoingCallStarter _startOutgoingCall;

  Future<bool> callBack({
    required String callerUserId,
    required String callerDisplayName,
    String? callerAvatarUrl,
    String? originalCallId,
  }) async {
    final notificationUserId = _clean(callerUserId);
    final callId = _clean(originalCallId);

    if (notificationUserId == null) {
      appLogger.e(
        '📞 Missed-call callback rejected because caller account ID is missing '
        '(originalCallId=${callId ?? 'none'})',
      );
      return false;
    }

    var resolvedUserId = notificationUserId;
    var callType = AOSCallType.audio;
    var resolvedDisplayName = _clean(callerDisplayName) ?? resolvedUserId;
    var resolvedAvatarUrl = _clean(callerAvatarUrl);

    if (callId != null) {
      try {
        final status = await _readCallStatus(callId: callId);
        callType = _parseCallType(status['call_type']);
        resolvedUserId = _clean(status['caller']) ?? resolvedUserId;
        resolvedDisplayName =
            _clean(status['caller_display_name']) ?? resolvedDisplayName;
        resolvedAvatarUrl =
            _clean(status['caller_avatar']) ?? resolvedAvatarUrl;
        appLogger.i(
          '📞 Missed-call callback resolved original call '
          '(originalCallId=$callId, caller=$resolvedUserId, '
          'type=${callType.name})',
        );
      } catch (error, stackTrace) {
        appLogger.w(
          '📞 Could not resolve original missed-call details; using '
          'notification identity and audio '
          '(originalCallId=$callId)',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    final participant = CallParticipant(
      userId: resolvedUserId,
      displayName: resolvedDisplayName,
      avatarUrl: resolvedAvatarUrl,
    );

    appLogger.i(
      '📞 Starting missed-call callback '
      '(originalCallId=${callId ?? 'none'}, receiver=$resolvedUserId, '
      'type=${callType.name})',
    );

    final started = await _startOutgoingCall(
      userId: resolvedUserId,
      callType: callType,
      receiver: participant,
    );

    if (!started) {
      appLogger.w(
        '📞 Missed-call callback did not start '
        '(originalCallId=${callId ?? 'none'}, receiver=$resolvedUserId)',
      );
    }

    return started;
  }

  AOSCallType _parseCallType(Object? value) {
    return value?.toString().trim().toLowerCase() == 'video'
        ? AOSCallType.video
        : AOSCallType.audio;
  }

  String? _clean(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
