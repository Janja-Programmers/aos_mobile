enum NotificationType {
  message,
  incomingCall,
  missedCall,
  callRejected,
  callEnded,
  adApproved,
  adRejected,
  liveStarted,
  follow,
  unknown,
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromString(String? type) {
    switch (type) {
      case 'message':
        return NotificationType.message;
      case 'incoming_call':
        return NotificationType.incomingCall;
      case 'missed_call':
        return NotificationType.missedCall;
      case 'call_rejected':
        return NotificationType.callRejected;
      case 'call_ended':
        return NotificationType.callEnded;
      case 'ad_approved':
        return NotificationType.adApproved;
      case 'ad_rejected':
        return NotificationType.adRejected;
      case 'live_started':
        return NotificationType.liveStarted;
      case 'follow':
        return NotificationType.follow;
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
      case NotificationType.liveStarted:
        return 'live_started';
      case NotificationType.follow:
        return 'follow';
      case NotificationType.unknown:
        return 'unknown';
    }
  }
}
