import 'dart:convert';
import 'dart:developer' as developer;

/// Low-cardinality runtime markers for calls-only device diagnostics.
///
/// These entries are visible through `adb logcat` even when the APK was not
/// started with `flutter run`. Never add tokens, session IDs, or full payloads.
class CallRuntimeLog {
  static const String tag = 'AOS_CALLS';

  const CallRuntimeLog._();

  static void write(
    String event, {
    String? callId,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    final safeDetails = <String, Object?>{
      if (callId != null && callId.trim().isNotEmpty) 'call_id': callId.trim(),
      ...details,
    };

    developer.log(
      jsonEncode(<String, Object?>{'event': event, ...safeDetails}),
      name: tag,
    );
  }
}
