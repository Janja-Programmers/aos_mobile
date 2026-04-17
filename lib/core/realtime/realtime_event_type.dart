enum RealtimeEventType {
  // Chat
  chatNewMessage,
  chatTyping,

  // Presence
  presenceUpdate,

  // Calls
  aosIncomingCall,
  aosCallAccepted,
  aosCallRejected,
  aosCallEnded,
  aosCallNotAnswered,

  // LIVE Events
  aosLiveStarted,
  aosLiveEnded,
  aosLiveViewerCount,

  // =========================
  // NOTIFICATIONS (NEW)
  // =========================
  aosFollow,
  aosMissedCall,
  aosAdApproved,
  aosAdRejected,
  aosAdExpired,
  aosVerificationApproved,
  aosVerificationRejected,
  aosNewShort,
  aosShortLike,
  aosShortComment,
  aosCommentReply,

  // =========================
  // PUSH (OPTIONAL HOOK)
  // =========================
  pushNotification,

  // Unknown
  unknown,
}

RealtimeEventType mapRealtimeEvent(String event) {
  switch (event) {
    case "aos_new_message":
      return RealtimeEventType.chatNewMessage;

    case "aos_typing":
      return RealtimeEventType.chatTyping;

    case "aos_presence_update":
      return RealtimeEventType.presenceUpdate;

    case "aos_incoming_call":
      return RealtimeEventType.aosIncomingCall;

    case "aos_call_accepted":
      return RealtimeEventType.aosCallAccepted;

    case "aos_call_rejected":
      return RealtimeEventType.aosCallRejected;

    case "aos_call_ended":
      return RealtimeEventType.aosCallEnded;

    case "aos_call_not_answered":
      return RealtimeEventType.aosCallNotAnswered;

    // LIVE Mapping
    case "aos_live_started":
      return RealtimeEventType.aosLiveStarted;

    case "aos_live_ended":
      return RealtimeEventType.aosLiveEnded;

    case "aos_live_viewer_count":
      return RealtimeEventType.aosLiveViewerCount;

    // =========================
    // NOTIFICATIONS
    // =========================
    case "aos_follow":
      return RealtimeEventType.aosFollow;

    case "aos_missed_call":
      return RealtimeEventType.aosMissedCall;

    case "aos_ad_approved":
      return RealtimeEventType.aosAdApproved;

    case "aos_ad_rejected":
      return RealtimeEventType.aosAdRejected;

    case "aos_ad_expired":
      return RealtimeEventType.aosAdExpired;

    case "aos_verification_approved":
      return RealtimeEventType.aosVerificationApproved;

    case "aos_verification_rejected":
      return RealtimeEventType.aosVerificationRejected;

    case "aos_new_short":
      return RealtimeEventType.aosNewShort;

    case "aos_short_like":
      return RealtimeEventType.aosShortLike;

    case "aos_short_comment":
      return RealtimeEventType.aosShortComment;

    case "aos_comment_reply":
      return RealtimeEventType.aosCommentReply;

    // =========================
    // PUSH (synthetic event if needed)
    // =========================
    case "push_notification":
      return RealtimeEventType.pushNotification;

    default:
      return RealtimeEventType.unknown;
  }
}
