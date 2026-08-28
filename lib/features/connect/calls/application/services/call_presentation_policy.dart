enum IncomingCallSurface { flutter, native }

/// AOS intentionally does not use Android full-screen intent.
///
/// On Android, a visible/resumed app owns the incoming-call UI in Flutter.
/// In background/terminated states the native CallStyle notification owns the
/// Answer/Decline surface. iOS continues to use native CallKit while alive.
IncomingCallSurface incomingCallSurfaceFor({
  required bool isAndroid,
  required bool isAppVisible,
}) {
  if (isAndroid && isAppVisible) {
    return IncomingCallSurface.flutter;
  }
  return IncomingCallSurface.native;
}
