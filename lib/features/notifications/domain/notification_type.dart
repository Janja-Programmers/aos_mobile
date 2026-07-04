enum NotificationType {
  message,
  incomingCall,
  missedCall,
  callRejected,
  callEnded,
  adApproved,
  adRejected,
  adExpired,
  verificationApproved,
  verificationRejected,
  liveStarted,
  follow,
  newShort,
  shortLike,
  shortComment,
  commentReply,
  unknown,
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromString(String? value) {
    return fromBackendValue(value);
  }

  static NotificationType fromBackendValue(String? value) {
    final normalized = value
        ?.trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (normalized) {
      // CHAT
      case 'message':
      case 'aos_new_message':
        return NotificationType.message;

      // CALLS
      // Backend type is "call", event is "aos_incoming_call".
      case 'call':
      case 'incoming_call':
      case 'aos_incoming_call':
        return NotificationType.incomingCall;

      case 'missed_call':
      case 'aos_missed_call':
        return NotificationType.missedCall;

      case 'call_rejected':
      case 'aos_call_rejected':
        return NotificationType.callRejected;

      case 'call_ended':
      case 'aos_call_ended':
        return NotificationType.callEnded;

      // ADS
      case 'ad_approved':
      case 'aos_ad_approved':
        return NotificationType.adApproved;

      case 'ad_rejected':
      case 'aos_ad_rejected':
        return NotificationType.adRejected;

      case 'ad_expired':
      case 'aos_ad_expired':
        return NotificationType.adExpired;

      // SELLER / PROFILE VERIFICATION
      case 'verification_approved':
      case 'aos_verification_approved':
        return NotificationType.verificationApproved;

      case 'verification_rejected':
      case 'aos_verification_rejected':
        return NotificationType.verificationRejected;

      // LIVE
      case 'live_started':
      case 'aos_live_started':
        return NotificationType.liveStarted;

      // FOLLOW
      case 'follow':
      case 'aos_follow':
        return NotificationType.follow;

      // SHORTS
      case 'new_short':
      case 'aos_new_short':
        return NotificationType.newShort;

      case 'short_like':
      case 'aos_short_like':
        return NotificationType.shortLike;

      case 'short_comment':
      case 'aos_short_comment':
        return NotificationType.shortComment;

      case 'comment_reply':
      case 'aos_comment_reply':
        return NotificationType.commentReply;

      default:
        return NotificationType.unknown;
    }
  }

  String get value {
    switch (this) {
      case NotificationType.message:
        return 'message';
      case NotificationType.incomingCall:
        return 'incoming_call';
      case NotificationType.missedCall:
        return 'missed_call';
      case NotificationType.callRejected:
        return 'call_rejected';
      case NotificationType.callEnded:
        return 'call_ended';
      case NotificationType.adApproved:
        return 'ad_approved';
      case NotificationType.adRejected:
        return 'ad_rejected';
      case NotificationType.adExpired:
        return 'ad_expired';
      case NotificationType.verificationApproved:
        return 'verification_approved';
      case NotificationType.verificationRejected:
        return 'verification_rejected';
      case NotificationType.liveStarted:
        return 'live_started';
      case NotificationType.follow:
        return 'follow';
      case NotificationType.newShort:
        return 'new_short';
      case NotificationType.shortLike:
        return 'short_like';
      case NotificationType.shortComment:
        return 'short_comment';
      case NotificationType.commentReply:
        return 'comment_reply';
      case NotificationType.unknown:
        return 'unknown';
    }
  }
}
