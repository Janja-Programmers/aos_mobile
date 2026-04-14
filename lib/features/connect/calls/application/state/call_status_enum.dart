enum CallStatus {
  idle,
  dialing,
  incoming,
  ringing,
  connecting,
  connected,
  rejected,
  missed,
  ended,
  failed,
  notAnswered,
}

/**
 * 1. Initiated
 * 
 * EVENT INCOMING ==> MARK CALL AS RINGING API
 * 2. Ringing
 * 3. Ongoing
 * 4. Cancelled
 * 5. Rejected
 * 6. Missed
 * 7. Ended
 * 8. Failed
 */
