# AOS Calls

## Status

**Implementation classification: Needs device validation.**

The Flutter integration has been hardened for Android foreground/background incoming-call presentation, native action recovery, LiveKit 2.10 audio lifecycle coordination, Bluetooth routing prerequisites, localization, accessibility, and stale-push protection. The backend remains authoritative for call lifecycle and media credentials.

The remaining acceptance gate is real-device validation using [`device-test-matrix.md`](device-test-matrix.md) plus the normal Flutter analyzer/test/build commands.

## Authority and ownership

`backend.zip` is authoritative for:

- canonical call/conversation IDs;
- caller/receiver eligibility, permissions and blocking;
- valid state transitions and stable errors;
- the 30-second unanswered-call timeout;
- LiveKit room names, tokens and WebSocket URL;
- realtime call events;
- call history, grouping and per-user deletion visibility;
- FCM device registration/delivery contracts.

Flutter owns:

- foreground call UI and navigation;
- Android native incoming-call notification integration;
- iOS CallKit integration supported by the current FCM delivery contract;
- durable native action/payload recovery;
- microphone/camera/Bluetooth permission preparation;
- LiveKit room/media lifecycle;
- local media controls and routing preferences;
- accessibility/localization of Flutter call surfaces;
- stale-client protection and reconciliation through `get_call_status`.

The frontend must not invent backend states, permissions, tokens, IDs, or transitions.

## Audited package versions

The call hardening intentionally pins these exact versions in `pubspec.yaml`:

```yaml
flutter_callkit_incoming: 3.1.5
livekit_client: 2.10.0
```

Why:

- `flutter_callkit_incoming` 3.1.0 added the background message handler and enhanced Android foreground-service support; 3.1.4/3.1.5 include terminated decline, audio-session, ringtone and foreground-service fixes. The 3.1.x event API uses sealed `CallEvent` classes.
- LiveKit 2.9.0 added `AudioSessionManagementMode.externalCallSystem`, audio engine availability, and modern `AudioManager` routing. LiveKit 2.10.0 retains those APIs and is the pinned AOS target.

Official references:

- https://pub.dev/packages/flutter_callkit_incoming/versions/3.1.5
- https://pub.dev/packages/flutter_callkit_incoming/changelog
- https://pub.dev/documentation/flutter_callkit_incoming/latest/flutter_callkit_incoming/FlutterCallkitIncoming-class.html
- https://pub.dev/documentation/flutter_callkit_incoming/latest/entities_call_event/CallEvent-class.html
- https://pub.dev/packages/livekit_client/versions/2.10.0
- https://pub.dev/packages/livekit_client/changelog
- https://pub.dev/documentation/livekit_client/latest/livekit_client/AudioSessionManagementMode.html
- https://pub.dev/documentation/livekit_client/latest/livekit_client/AudioManager-class.html
- https://github.com/livekit-examples/flutter-callkit

Do not upgrade either dependency independently of this feature without re-running the call device matrix and inspecting the package changelog/native manifest impact.

## Backend contract consumed by Flutter

### Lifecycle methods

| Operation | Method | Frontend use |
| --- | --- | --- |
| Start | `initiate_call` | Caller starts audio/video call in a conversation |
| Ringing acknowledgement | `mark_call_ringing` | Receiver acknowledges ringing presentation |
| Accept | `accept_call` | Receiver accepts an active incoming call |
| Reject | `reject_call` | Receiver declines before connection |
| Cancel | `cancel_call` | Caller cancels before connection |
| End | `end_call` | Participant ends an ongoing call |
| Recovery | `get_call_status` | Authoritative state reconciliation |
| Media recovery | `get_call_token` | Refresh/join media credentials for ongoing call |
| History | `list_calls` | Paginated/filterable call history |

Backend statuses represented by Flutter:

```text
initiated
ringing
ongoing
ended
rejected
missed
cancelled
failed
```

`initiated`, `ringing`, and `ongoing` are non-terminal. Backend terminal status always wins over stale local state.

### Realtime events

Flutter consumes the backend call events already defined by the Calls contract, including:

```text
aos_incoming_call
aos_call_ringing
aos_call_accepted
aos_call_rejected
aos_call_cancelled
aos_call_ended
aos_call_not_answered
aos_call_video_upgrade_requested
aos_call_video_upgrade_accepted
aos_call_video_upgrade_declined
```

Realtime is a delivery mechanism, not lifecycle authority. Recovery uses `get_call_status`.

## State ownership

| Owner | Responsibility |
| --- | --- |
| `CallManager` | Active call state, backend actions, media lifecycle coordination, duplicate/stale action protection, call history |
| `CallRepository` | Typed boundary over backend Calls methods |
| `SocketCallListener` | Global realtime call event delivery |
| `PushNotificationService` | FCM permission/token lifecycle, foreground/tap/terminated message handling |
| `IncomingCallBootstrapper` | Validates incoming push payload through backend status before hydrating Flutter call state |
| `CallKitService` | Native presentation, backend-ID/native-UUID mapping, sealed CallKit events, iOS audio-session event handoff |
| `callKitBackgroundMessageHandler` | Persists Accept/Decline/End/Timeout while normal foreground Riverpod handling is unavailable |
| `PendingCallKitActionReplayer` | Idempotent retry-safe native action replay |
| `CallKitRecoveryService` | Gives native action recovery priority over pending ringing restoration |
| `CallMediaService` | Required media permission preparation, best-effort Bluetooth preparation, LiveKit join/leave/routing |
| `LiveKitService` | Room connection, tracks, `AudioManager` audio lifecycle and routing |
| `CallNavigationListener` | Sole call-session route owner |
| `CallKitStateListener` | Native state mirroring and visible-lifecycle recovery trigger |

Backend and Flutter UI phases are intentionally separate:

```text
Backend:
initiated → ringing → ongoing → terminal

Flutter:
idle
outgoingStarting
outgoingRinging
incomingRinging
joiningRoom
inCall
finished / cancelled / error
```

`ongoing` does not mean media is already connected. Flutter stays in `joiningRoom` until LiveKit joins successfully.

## Incoming-call presentation policy

AOS intentionally does **not** request or use Android full-screen intent.

`AndroidManifest.xml` keeps:

```xml
<uses-permission
    android:name="android.permission.USE_FULL_SCREEN_INTENT"
    tools:node="remove" />
```

The call code must not invoke the plugin's full-screen-intent permission APIs.

### Android — app visible/resumed

```text
incoming realtime/foreground FCM
→ backend validation/hydration
→ incomingRinging
→ CallNavigationListener enters CallSessionScreen
→ RingingScreen / VideoRingingScreen
→ localized Flutter Answer / Decline controls
```

The native incoming-call notification is still requested by `CallKitStateListener`; it owns the ringtone and provides the background/system action surface if the app loses visibility during ringing. `AndroidParams.isFullScreen` and `isShowFullLockedScreen` are both false.

### Android — background/terminated/locked

```text
high-priority data FCM
→ top-level background handler
→ reject stale push at >= 30 seconds when sentTime is available
→ persist native call payload/UUID mapping
→ flutter_callkit_incoming notification/foreground-service path
→ Answer / Decline native action
→ background callback persists action
→ authenticated Flutter runtime replays against backend state
```

Expected presentation is a high-priority call notification with actions, not a forced full-screen activity.

Android 13+ notification permission remains important. Android documents that when notification permission is denied, an app may still start an FGS but its FGS notice can be visible only in Task Manager instead of the notification drawer. Test this explicitly.

Official references:

- https://developer.android.com/develop/ui/views/notifications/call-style
- https://developer.android.com/develop/ui/compose/notifications/notification-permission
- https://pub.dev/packages/flutter_callkit_incoming

### iOS

Incoming ringing stays native CallKit when the supported delivery path reaches the application.

Current AOS backend registration/delivery supports FCM/APNs notification tokens but does **not** expose a PushKit VoIP-token registration/delivery contract. Therefore this frontend does not invent a frontend-only PushKit pipeline.

`Info.plist` enables:

```text
audio
fetch
remote-notification
```

It intentionally does not declare `voip` until the backend can store and target a VoIP token and the full PushKit lifecycle is implemented.

This is a real limitation: `flutter_callkit_incoming` documents PushKit for reliable iOS VoIP wake, and Firebase documents that after an iOS user swipes an app away, background messaging does not resume until the app is reopened. Terminated/swipe-away iOS call reliability is therefore **backend-capability blocked**, not solved by Dart-only code.

Official references:

- https://pub.dev/packages/flutter_callkit_incoming
- https://firebase.google.com/docs/cloud-messaging/flutter/receive
- https://github.com/livekit-examples/flutter-callkit

## Native action recovery

`flutter_callkit_incoming` 3.1.5 exposes `onBackgroundMessage`, which AOS registers in `main.dart` before normal application startup completes.

Supported durable actions:

```text
accept
decline
ended
timeout
```

The background handler persists:

```text
call_id
native callkit UUID when available
action
created_at_ms
```

Recovery order is intentional:

```text
authenticated Flutter runtime available
→ replay pending native action
→ if action outcome is temporarily unavailable, retain it and stop
→ if action is resolved/terminal, dedupe + clear matching ringing payload
→ only then attempt pending incoming-call restoration
```

Rules:

- backend status is revalidated before the native action is applied;
- a transient backend/network failure does not mark an action handled;
- unresolved actions remain pending for a later startup/resume;
- action signatures are retained for seven days for duplicate protection;
- pending actions at or beyond five minutes are discarded with the matching stale ringing payload;
- foreground lifecycle recovery re-runs when the authenticated app becomes visible.

Never dispatch an Accept/Decline based only on stale local UI state or message text.

## Incoming push freshness

The backend unanswered-call timeout is 30 seconds. `incoming_call_push_freshness.dart` mirrors that client-side only to avoid presenting obviously stale background messages:

```text
age < 30 seconds    → eligible for backend reconciliation
age >= 30 seconds   → do not present
missing sentTime    → do not guess; query backend when Flutter is available
future sentTime     → tolerate clock skew; backend remains authoritative
```

This is not a second business rule. Backend status still decides whether the call is actionable.

## LiveKit 2.10 media lifecycle

### Permission preparation

`CallMediaService.prepareForCall` performs:

```text
Android Bluetooth permission request (best effort)
→ microphone permission (required)
→ camera permission for video (required)
→ configure external-call-system audio mode
```

Bluetooth denial must **not** block handset/wired calling. Microphone denial blocks all calls; camera denial blocks video calls.

The accepted incoming path carries `permissionsAlreadyPrepared` into `joinCall` so microphone/camera permissions are not requested twice.

### Android Bluetooth

The manifest declares the LiveKit/WebRTC Bluetooth prerequisites:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

LiveKit's Flutter documentation also demonstrates runtime `Permission.bluetooth` and `Permission.bluetoothConnect` requests.

Speaker routing uses:

```dart
AudioManager.instance.setSpeakerOutputPreferred(...)
```

LiveKit documents that the non-forced preference preserves wired/Bluetooth headset priority. AOS does not force speaker over an attached headset.

Official reference:

- https://pub.dev/packages/livekit_client/versions/2.10.0
- https://pub.dev/documentation/livekit_client/latest/livekit_client/AudioManager-class.html

### iOS CallKit audio activation

Before joining a call, AOS selects:

```dart
AudioSessionManagementMode.externalCallSystem
```

LiveKit documents this mode for an external telephony owner such as iOS CallKit. LiveKit may configure category/mode/options but must not own session activation/deactivation.

AOS also gates WebRTC engine availability from the plugin's `CallEventActionCallToggleAudioSession` event:

```text
CallKit active   → AudioEngineAvailability.defaultAvailability
CallKit inactive → AudioEngineAvailability.none
```

LiveKit documents `setEngineAvailability` as iOS/macOS-only and a no-op elsewhere, so this cross-platform code does not disable Android audio.

On call leave, AOS restores automatic LiveKit audio-session management for other app media use.

Official references:

- https://pub.dev/documentation/livekit_client/latest/livekit_client/AudioSessionManagementMode.html
- https://pub.dev/documentation/livekit_client/latest/livekit_client/AudioEngineAvailability-class.html
- https://github.com/livekit-examples/flutter-callkit

## Camera privacy

An outgoing video caller may start a local preview while ringing.

An incoming video call must **not** start local camera preview before the user answers. Camera publication starts only through the accepted call media path after explicit user action and permission handling.

## CallKit identity mapping

Backend call IDs and native CallKit UUIDs are separate identifiers.

- Backend call ID is the canonical API/realtime identifier.
- Native UUID is generated for CallKit/plugin presentation.
- `extra.call_id` carries the canonical backend ID through native events.
- mapping is persisted so cold-start native actions can recover the backend call.

Do not replace a backend call ID with the native UUID in API requests.

## Navigation

`CallNavigationListener` is the sole Flutter route owner.

It observes both call state and app visibility:

- foreground Android `incomingRinging` → call session;
- background Android `incomingRinging` → native surface only;
- iOS `incomingRinging` → native CallKit only;
- outgoing start/ringing → call session;
- joining/in-call → call session;
- terminal/idle → leave call session when it was the active call route.

No API, socket, FCM, CallKit service, or presentation widget should independently navigate the app after a lifecycle action.

## Accessibility and localization

Foreground incoming Answer/Decline controls:

- use ARB-backed localized labels;
- expose button semantics and accessible labels;
- do not rely on color/icon alone;
- use >= 68x68 visual action targets;
- wrap action areas in `SafeArea`;
- support RTL directionality;
- are covered at 320px width and 200% text scaling.

Changed call UI copy is present in English, French, Swahili, Arabic, and Chinese ARBs.

## Error/offline behavior

- Backend validation is authoritative; frontend validation only improves UX.
- Native action reconciliation retains pending action state on transient failure.
- Active calls periodically reconcile backend status in `CallManager` so lost socket terminal events do not leave the client permanently active.
- LiveKit join failure must not fabricate an ongoing media state.
- Bluetooth permission failure falls back to available non-Bluetooth routes.
- Required microphone/camera permission failure is explicit and blocks the relevant media path.
- Duplicate native/realtime actions are guarded by call IDs/action locks and handled-action signatures.

## Automated tests

Call-specific coverage includes:

- exact audited package pins;
- 3.1.5 background handler/sealed event contract;
- retry-safe pending action replay;
- 30-second push freshness boundaries;
- Android foreground/native presentation policy;
- FSI prohibition and manifest Bluetooth declarations;
- LiveKit external-call audio lifecycle source contract;
- incoming video pre-answer camera privacy;
- iOS implemented background-mode/logo/audio configuration contract;
- outgoing native CallKit registration preservation;
- notification token registration independent of display permission;
- incoming action semantics, 320px layout, 200% text scale, and RTL;
- existing call payload/history/callback tests.

Run in a Flutter/CocoaPods-enabled environment:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter build apk --debug
cd ios && pod install && cd ..
```

The source bundle for this hardening was prepared in an environment without Flutter/Dart/CocoaPods. Therefore `flutter pub get` must regenerate the authoritative hosted-package integrity hashes in `pubspec.lock`, and `pod install` must refresh `ios/Podfile.lock` for LiveKit 2.10.0 and its WebRTC dependency before release. Do not hand-edit CocoaPods checksums to simulate this step.

For release validation additionally inspect the merged Android manifest and signed iOS entitlements. See [`implementation-validation.md`](implementation-validation.md) for the static checks performed on the delivered source and the toolchain checks intentionally left to the build environment.

## Physical-device validation

Use [`device-test-matrix.md`](device-test-matrix.md). Do not treat emulator-only CallKit/Bluetooth results as release acceptance.

Important terminology:

- **terminated** in the Android matrix means swiped away/process not resident, not Android Settings → Force stop;
- **force stop** intentionally blocks ordinary background delivery and is not a valid terminated-call acceptance test;
- iOS swipe-away killed-state incoming reliability remains blocked until PushKit backend capability exists.

## Security and privacy

- No media token is fabricated or persisted as a fallback default.
- Backend status is queried before recovery actions.
- Canonical IDs stay distinct from presentation IDs.
- No plaintext credential or secret is added by this feature.
- Incoming video camera access waits for explicit Answer.
- Full-screen intent is deliberately removed to comply with the application's Play policy decision.

## Known limitations

1. **iOS terminated/swipe-away incoming VoIP: backend blocked.** A complete PushKit implementation requires backend VoIP-token registration and APNs VoIP delivery. Do not add `voip` mode or native PushKit registration alone.
2. **Notification permission/channel state is user-controlled.** On Android 13+, denied notifications can remove the visible notification-drawer call surface. The app must be device-tested with both allowed and denied states.
3. **OEM power management differs.** Samsung/Xiaomi/Oppo/etc. background behavior must be verified physically; the frontend cannot guarantee vendor task-killer behavior.
4. LiveKit's external call-system and engine-availability APIs are marked experimental by LiveKit; re-audit on every LiveKit upgrade.

## Release / OTA classification

**Play Store/App Store release required.**

Reasons:

- `flutter_callkit_incoming` native plugin version changed;
- `livekit_client`/WebRTC native dependency graph changed;
- Android manifest changed;
- iOS `Info.plist` and asset catalog changed.

This is not a Shorebird-only update. Later Dart-only call UI/logic fixes may be OTA candidates after this binary baseline is shipped, subject to normal Shorebird compatibility review.
