# Calls

## Ownership

- Firebase Messaging classifies delivery.
- `CallKitService` owns native incoming/outgoing presentation and native events.
- `CallManager` owns backend actions and active call state.
- `CallMediaService` owns permissions and LiveKit connection.
- Call navigation listeners own active-call routes. Generic notification navigation never owns incoming calls.

## Backend push contract

Incoming calls use event `aos_incoming_call`, canonical `call_id`, channel ID `aos_calls`, Android FCM priority `high`, notification priority `max`, and TTL 30 seconds. General notifications use `aos_notifications`.

The audited backend currently sends a notification block plus data. On Android, background notification messages are presented by the system tray and data reaches Flutter after a tap. Automatic terminated-state CallKit presentation therefore requires the backend call push to be data-only (or an equivalent native delivery path); Dart cannot override Android's system handling of a background notification message.

## Plugin baseline

This patch pins `flutter_callkit_incoming` to `3.0.0`, the exact version in the earlier working app. Version 3.1.x introduced self-managed Telecom and enhanced foreground-service handling. The observed target-SDK-36 microphone foreground-service exception is in that changed area, so 3.1.x is not used for this recovery build.

The 3.0.0 plugin manifest already declares `MANAGE_OWN_CALLS`, `FOREGROUND_SERVICE_PHONE_CALL`, and its `phoneCall` service. Do not add microphone/camera foreground-service permissions merely to silence a 3.1.x exception.

## Android full-screen intent permission

`USE_FULL_SCREEN_INTENT` remains declared because incoming calls are a valid
full-screen use case. On Android 14+, the operating system may still revoke this
special access. The app now checks access silently and never opens the settings
page during application initialization.

Ownership is explicit:

- `PushNotificationService` owns the standard notification permission and only
  requests it while the status is `notDetermined`.
- `CallKitService` reads full-screen-intent access without side effects.
- `CallListScreen` shows a contextual banner only when access is unavailable.
  Android settings open only after the user taps **Open settings**.
- The permission state is refreshed when the app resumes from settings.

If access is denied, Android may display an expanded heads-up incoming-call
notification instead of launching the full-screen call activity. The app must
not repeatedly send the user to settings.

## Device logging without flutter run

`flutter run` is not required. Install the debug APK, connect USB debugging, and run one of these before placing a call:

```bash
adb logcat -c
adb logcat -v time AOS_CALLS:V FirebaseMessaging:V AndroidRuntime:E '*:S'
```

To capture everything to a file while the app is backgrounded or terminated:

```bash
adb logcat -c
adb logcat -v time > aos-call-terminated.log
```

Reproduce the call, then press `Ctrl+C`. On Windows CMD/PowerShell, filter a completed capture with:

```powershell
adb logcat -d -v time | Select-String -Pattern "AOS_CALLS|FirebaseMessaging|Callkit|ForegroundService|SecurityException|AndroidRuntime"
```

Android Studio Logcat also works without launching from the IDE: attach the physical device, select package `com.africaonlinestores.app`, and reproduce using the already installed APK.

Interpretation:

- `AOS_CALLS/fcm_background_received` proves Dart's background handler ran.
- A tray notification with no `fcm_background_received` marker confirms Android consumed a notification-block message before Dart.
- `callkit_show_requested` without `callkit_show_completed` indicates a plugin/native failure.
- `callkit_event` confirms accept/decline/end reached Dart.

## Validation

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze lib test/features/connect/calls
flutter test test/features/connect/calls
flutter build apk --debug
```

Use a clean install before ringtone testing because Android notification channels persist.

## Release impact

The exact dependency pin is native dependency resolution and requires a Play Store/App Store build, not Shorebird-only delivery.
