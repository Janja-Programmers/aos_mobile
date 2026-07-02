import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';

class CallKitParamsMapper {
  const CallKitParamsMapper();

  CallKitParams incoming({
    required String callkitUuid,
    required String callId,
    required AOSCallType callType,
    CallParticipant? caller,
    String? roomName,
  }) {
    final isVideo = callType == AOSCallType.video;

    final callerUserId = _cleanString(caller?.userId);
    final callerName =
        _cleanString(caller?.displayName) ?? callerUserId ?? 'AOS User';

    final callerAvatar = _cleanString(caller?.avatarUrl);
    final cleanRoomName = _cleanString(roomName);

    final callLabel = isVideo ? 'Incoming video call' : 'Incoming voice call';

    return CallKitParams(
      id: callkitUuid,
      nameCaller: callerName,
      appName: 'Africa Online Stores',
      handle: callLabel,
      avatar: callerAvatar,
      type: isVideo ? 1 : 0,
      duration: 30000,
      extra: {
        'call_id': callId,
        'callkit_uuid': callkitUuid,
        'call_type': isVideo ? 'video' : 'audio',
        'caller_display_name': callerName,
        'caller': callerUserId,
        'caller_avatar': callerAvatar,
        'room_name': cleanRoomName,
      },

      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        isShowCallID: false,
        isShowFullLockedScreen: true,
        isFullScreen: true,
        isImportant: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#FFFFFF',
        textColor: '#111111',
        actionColor: '#16A34A',
        incomingCallNotificationChannelName: 'AOS Calls',
        missedCallNotificationChannelName: 'Missed Calls',
        textAccept: 'Answer',
        textDecline: 'Reject',
      ),

      ios: IOSParams(
        handleType: 'generic',
        supportsVideo: isVideo,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        configureAudioSession: false,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
  }

  String? _cleanString(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}
