const Duration incomingCallPushTtl = Duration(seconds: 30);

/// Mirrors the backend's 30-second incoming-call push TTL.
///
/// FCM does not guarantee [sentTime], so a missing value is not treated as
/// stale. A future timestamp is tolerated for device/server clock skew; the
/// backend is still authoritative when the action is reconciled.
bool isIncomingCallPushFresh({
  required DateTime? sentTime,
  required DateTime now,
}) {
  if (sentTime == null) return true;

  final age = now.difference(sentTime);
  if (age.isNegative) return true;

  return age < incomingCallPushTtl;
}
