import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';

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
    final callerAvatar = normalizeMediaUrl(_cleanString(caller?.avatarUrl));
    final cleanRoomName = _cleanString(roomName);

    return CallKitParams(
      id: callkitUuid,
      nameCaller: callerName,
      appName: 'Africa Online Stores',
      handle: isVideo ? 'Incoming video call' : 'Incoming audio call',
      avatar: callerAvatar,
      type: isVideo ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      // The backend owns persistent missed-call notifications and their
      // callback action. Disable the plugin's duplicate notification so there
      // is one callback owner and one canonical caller identity path.
      missedCallNotification: const NotificationParams(
        showNotification: false,
        isShowCallback: false,
      ),
      extra: <String, dynamic>{
        'event': 'aos_incoming_call',
        'type': 'incoming_call',
        'notification_type': 'incoming_call',
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
        isImportant: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#FFFFFF',
        textColor: '#111111',
        actionColor: '#16A34A',
        incomingCallNotificationChannelName: 'AOS Calls',
        missedCallNotificationChannelName: 'Missed Calls',
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

  CallKitParams outgoing({
    required String callkitUuid,
    required String callId,
    required AOSCallType callType,
    CallParticipant? receiver,
  }) {
    final isVideo = callType == AOSCallType.video;
    final receiverUserId = _cleanString(receiver?.userId);
    final receiverName =
        _cleanString(receiver?.displayName) ?? receiverUserId ?? 'AOS User';
    final receiverAvatar = normalizeMediaUrl(_cleanString(receiver?.avatarUrl));

    return CallKitParams(
      id: callkitUuid,
      nameCaller: receiverName,
      appName: 'Africa Online Stores',
      handle: isVideo ? 'Video call' : 'Audio call',
      avatar: receiverAvatar,
      type: isVideo ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      callingNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Calling…',
        callbackText: 'Cancel',
      ),
      extra: <String, dynamic>{
        'event': 'aos_outgoing_call',
        'type': 'outgoing_call',
        'call_id': callId,
        'callkit_uuid': callkitUuid,
        'call_type': isVideo ? 'video' : 'audio',
        'receiver': receiverUserId,
        'receiver_display_name': receiverName,
        'receiver_avatar': receiverAvatar,
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        isShowCallID: false,
        isImportant: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#FFFFFF',
        textColor: '#111111',
        actionColor: '#16A34A',
        incomingCallNotificationChannelName: 'AOS Calls',
        missedCallNotificationChannelName: 'Missed Calls',
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
