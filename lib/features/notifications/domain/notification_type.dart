enum NotificationType {
  message,
  incomingCall,
  missedCall,
  callRejected,
  callEnded,
  adApproved,
  adRejected,
  adExpired,
  reviewReceived,
  reviewApproved,
  reviewRejected,
  verificationApproved,
  verificationRejected,
  liveStarted,
  follow,
  newShort,
  shortLike,
  shortComment,
  shortMention,
  commentReply,
  unknown,
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromString(String? value) {
    return fromBackendValue(value);
  }

  static NotificationType fromBackendValue(String? value) {
    final String? normalized = value
        ?.trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return switch (normalized) {
      'message' || 'aos_new_message' => NotificationType.message,
      'call' ||
      'incoming_call' ||
      'aos_incoming_call' => NotificationType.incomingCall,
      'missed_call' || 'aos_missed_call' => NotificationType.missedCall,
      'call_rejected' || 'aos_call_rejected' => NotificationType.callRejected,
      'call_ended' || 'aos_call_ended' => NotificationType.callEnded,
      'ad_approved' || 'aos_ad_approved' => NotificationType.adApproved,
      'ad_rejected' || 'aos_ad_rejected' => NotificationType.adRejected,
      'ad_expired' || 'aos_ad_expired' => NotificationType.adExpired,
      'review_received' ||
      'aos_review_received' => NotificationType.reviewReceived,
      'review_approved' ||
      'aos_review_approved' => NotificationType.reviewApproved,
      'review_rejected' ||
      'aos_review_rejected' => NotificationType.reviewRejected,
      'verification_approved' ||
      'aos_verification_approved' => NotificationType.verificationApproved,
      'verification_rejected' ||
      'aos_verification_rejected' => NotificationType.verificationRejected,
      'live_started' || 'aos_live_started' => NotificationType.liveStarted,
      'follow' || 'aos_follow' => NotificationType.follow,
      'new_short' || 'aos_new_short' => NotificationType.newShort,
      'short_like' || 'aos_short_like' => NotificationType.shortLike,
      'short_comment' || 'aos_short_comment' => NotificationType.shortComment,
      'short_mention' || 'aos_short_mention' => NotificationType.shortMention,
      'comment_reply' || 'aos_comment_reply' => NotificationType.commentReply,
      _ => NotificationType.unknown,
    };
  }

  String get value {
    return switch (this) {
      NotificationType.message => 'message',
      NotificationType.incomingCall => 'incoming_call',
      NotificationType.missedCall => 'missed_call',
      NotificationType.callRejected => 'call_rejected',
      NotificationType.callEnded => 'call_ended',
      NotificationType.adApproved => 'ad_approved',
      NotificationType.adRejected => 'ad_rejected',
      NotificationType.adExpired => 'ad_expired',
      NotificationType.reviewReceived => 'review_received',
      NotificationType.reviewApproved => 'review_approved',
      NotificationType.reviewRejected => 'review_rejected',
      NotificationType.verificationApproved => 'verification_approved',
      NotificationType.verificationRejected => 'verification_rejected',
      NotificationType.liveStarted => 'live_started',
      NotificationType.follow => 'follow',
      NotificationType.newShort => 'new_short',
      NotificationType.shortLike => 'short_like',
      NotificationType.shortComment => 'short_comment',
      NotificationType.shortMention => 'short_mention',
      NotificationType.commentReply => 'comment_reply',
      NotificationType.unknown => 'unknown',
    };
  }
}
