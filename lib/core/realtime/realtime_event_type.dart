enum RealtimeEventType {
  // Chat
  chatNewMessage,
  chatTyping,
  aosMessageStatus,
  aosMessageEdited,
  aosMessagesDeleted,
  aosMessageReactionUpdated,

  // Presence
  presenceUpdate,

  // Calls
  aosIncomingCall,
  aosCallRinging,
  aosCallAccepted,
  aosCallRejected,
  aosCallEnded,
  aosCallNotAnswered,
  aosCallCancelled,
  aosCallVideoUpgradeRequested,
  aosCallVideoUpgradeAccepted,
  aosCallVideoUpgradeDeclined,
  aosCallVideoUpgradeCancelled,

  // LIVE Events
  aosLiveStarted,
  aosLiveEnded,
  aosLiveViewerCount,
  aosLiveViewerJoined,
  aosLiveViewerLeft,
  aosLiveComment,
  aosLiveCommentDeleted,
  aosLiveReaction,
  aosLiveCohostInvited,
  aosLiveCohostRequestReceived,
  aosLiveCohostAccepted,
  aosLiveCohostRejected,
  aosLiveCohostCancelled,
  aosLiveCohostActivated,
  aosLiveCohostStarted,
  aosLiveCohostEnded,

  // Notifications
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

  // Push
  pushNotification,

  // Unknown
  unknown,
}

RealtimeEventType mapRealtimeEvent(String event) {
  switch (event) {
    // =========================
    // CHAT
    // =========================
    case "aos_new_message":
      return RealtimeEventType.chatNewMessage;

    case "aos_typing":
      return RealtimeEventType.chatTyping;

    case "aos_message_status":
      return RealtimeEventType.aosMessageStatus;

    case "aos_message_edited":
      return RealtimeEventType.aosMessageEdited;

    case "aos_messages_deleted":
      return RealtimeEventType.aosMessagesDeleted;

    case "aos_message_reaction_updated":
      return RealtimeEventType.aosMessageReactionUpdated;

    // =========================
    // PRESENCE
    // =========================
    case "aos_presence_update":
      return RealtimeEventType.presenceUpdate;

    // =========================
    // CALLS
    // =========================
    case "aos_incoming_call":
      return RealtimeEventType.aosIncomingCall;

    case "aos_call_ringing":
      return RealtimeEventType.aosCallRinging;

    case "aos_call_accepted":
      return RealtimeEventType.aosCallAccepted;

    case "aos_call_cancelled":
      return RealtimeEventType.aosCallCancelled;

    case "aos_call_rejected":
      return RealtimeEventType.aosCallRejected;

    case "aos_call_ended":
      return RealtimeEventType.aosCallEnded;

    case "aos_call_not_answered":
      return RealtimeEventType.aosCallNotAnswered;

    case "aos_call_video_upgrade_request":
    case "aos_call_video_upgrade_requested":
      return RealtimeEventType.aosCallVideoUpgradeRequested;

    case "aos_call_video_upgrade_accepted":
      return RealtimeEventType.aosCallVideoUpgradeAccepted;

    case "aos_call_video_upgrade_declined":
      return RealtimeEventType.aosCallVideoUpgradeDeclined;

    case "aos_call_video_upgrade_cancelled":
    case "aos_call_video_upgrade_canceled":
      return RealtimeEventType.aosCallVideoUpgradeCancelled;

    // =========================
    // LIVE
    // =========================
    case "aos_live_started":
      return RealtimeEventType.aosLiveStarted;

    case "aos_live_ended":
      return RealtimeEventType.aosLiveEnded;

    case "aos_live_viewer_count":
      return RealtimeEventType.aosLiveViewerCount;

    case "aos_live_viewer_joined":
      return RealtimeEventType.aosLiveViewerJoined;

    case "aos_live_viewer_left":
      return RealtimeEventType.aosLiveViewerLeft;

    case "aos_live_comment":
    case "aos_live_message":
      return RealtimeEventType.aosLiveComment;

    case "aos_live_comment_deleted":
    case "aos_live_message_deleted":
      return RealtimeEventType.aosLiveCommentDeleted;

    case "aos_live_reaction":
      return RealtimeEventType.aosLiveReaction;

    case "aos_live_cohost_invited":
      return RealtimeEventType.aosLiveCohostInvited;

    case "aos_live_cohost_request_received":
      return RealtimeEventType.aosLiveCohostRequestReceived;

    case "aos_live_cohost_accepted":
      return RealtimeEventType.aosLiveCohostAccepted;

    case "aos_live_cohost_rejected":
      return RealtimeEventType.aosLiveCohostRejected;

    case "aos_live_cohost_cancelled":
    case "aos_live_cohost_canceled":
      return RealtimeEventType.aosLiveCohostCancelled;

    case "aos_live_cohost_activated":
      return RealtimeEventType.aosLiveCohostActivated;

    case "aos_live_cohost_started":
      return RealtimeEventType.aosLiveCohostStarted;

    case "aos_live_cohost_ended":
      return RealtimeEventType.aosLiveCohostEnded;

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
    // PUSH
    // =========================
    case "push_notification":
      return RealtimeEventType.pushNotification;

    default:
      return RealtimeEventType.unknown;
  }
}
