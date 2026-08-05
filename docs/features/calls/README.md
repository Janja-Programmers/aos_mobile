# AOS Calls

## Status

The validated Android flows are working for foreground incoming calls, resident-background incoming calls, native Accept, missed calls, callback, LiveKit media, and normal end-call cleanup.

This hardening pass addresses the remaining lifecycle issues found during device testing:

- the brief Home flash between native Accept and `CallSessionScreen`;
- duplicate incoming-call hydration;
- duplicate microphone permission checks;
- duplicate native CallKit presentation after recovery;
- delayed/stale terminated-state incoming payloads;
- native Accept actions received before the normal Dart listener is ready;
- insufficient lifecycle and timing diagnostics.

The new terminated-state recovery path requires device revalidation before the feature is classified as fully production-validated.

## Authority and ownership

`backend.zip` remains authoritative for:

- canonical call and conversation IDs;
- caller/receiver permissions and blocking;
- lifecycle transitions and stable errors;
- LiveKit room names, tokens, and WebSocket URL;
- the 30-second answer window;
- realtime events;
- missed-call notifications;
- call history, grouping, and per-user deletion visibility.

The Flutter frontend owns:

- native incoming/outgoing call presentation;
- FCM and realtime delivery handling;
- camera and microphone permissions;
- LiveKit connection and local media controls;
- UI phases and navigation;
- lifecycle recovery and stale-event protection;
- device diagnostics.

The frontend must never infer backend permissions or force an invalid state transition.

## Backend contract used by Flutter

### Lifecycle endpoints

| Operation | Endpoint method | Valid frontend use |
| --- | --- | --- |
| Start | `initiate_call` | Caller starts audio/video call in an existing conversation |
| Ringing acknowledgement | `mark_call_ringing` | Receiver confirms incoming UI was presented |
| Accept | `accept_call` | Receiver accepts an `initiated` or `ringing` call |
| Reject | `reject_call` | Receiver declines before connection |
| Cancel | `cancel_call` | Caller cancels before connection |
| End | `end_call` | Either participant ends an ongoing call |
| Recovery | `get_call_status` | Validate stale, background, or restored call state |
| Token recovery | `get_call_token` | Rejoin an active call when media credentials are absent |
| History | `list_calls` | Paginated/filterable call history |

Backend statuses represented in Flutter:

```text
initiated
ringing
ongoing
cancelled
rejected
missed
ended
failed
```

Active backend statuses are `initiated`, `ringing`, and `ongoing`. Terminal status always wins over local UI state.

### Realtime events

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

Realtime event labels describe an event. `get_call_status` remains the canonical recovery source after lifecycle interruption.

## Architecture and state ownership

### Main owners

| Owner | Responsibility |
| --- | --- |
| `CallManager` | One active call domain, backend actions, UI phase, history, duplicate-action locks, stale-result protection |
| `CallRepository` | Typed frontend boundary over Calls APIs |
| `SocketCallListener` | Global Frappe realtime call events |
| `PushNotificationService` | FCM listeners, token registration, terminated launch recovery |
| `IncomingCallBootstrapper` | Validates a push payload through `get_call_status` before reconstructing Flutter state |
| `CallKitService` | Native CallKit presentation, UUID mapping, event handoff, native-state reconciliation |
| `CallKitEarlyActionCapture` | Captures native actions before Riverpod and normal service startup |
| `CallKitPendingActionRecoveryService` | Replays persisted Accept/Decline/End/Timeout after authenticated startup |
| `CallMediaService` | Permission preparation and LiveKit join/leave/media controls |
| `CallNavigationListener` | Sole Flutter call-route owner |
| `CallKitStateListener` | Mirrors call state to native CallKit without duplicate presentation |
| `MissedCallCallbackService` | Starts a new call from a persistent backend missed-call notification |

### Backend and UI states are separate

```text
Backend lifecycle:
initiated → ringing → ongoing → terminal

Flutter UI lifecycle:
idle
outgoingStarting
outgoingRinging
incomingRinging
joiningRoom
inCall
finished / cancelled / error
```

`ongoing` means the backend accepted the call. It does not mean LiveKit media is connected. The UI remains in `joiningRoom` until LiveKit completes.

## Call flows

### Outgoing call

```text
Entry point
→ open_conversation
→ initiate_call
→ store canonical call and LiveKit credentials
→ register outgoing native CallKit call
→ CallSessionScreen/outgoing ringing
→ aos_call_accepted
→ join LiveKit
→ inCall
```

Repeated taps are suppressed by call action locks. A terminal backend event cancels any stale room-join completion.

### Foreground incoming call

```text
aos_incoming_call via realtime or foreground FCM
→ validate/normalize payload
→ mark_call_ringing best effort
→ incomingRinging state
→ native CallKit surface and ringtone
```

Flutter does not push its own incoming-ringing route. Native CallKit owns ringing; the AOS session route begins when the call is accepted.

### Resident-background incoming call

```text
FCM background handler
→ persist incoming payload/UUID mapping
→ show native CallKit surface
→ user opens or accepts
→ resume MainActivity
→ validate backend state
→ accept/reject/end
```

Realtime can disconnect while the application is backgrounded. FCM is the required fallback for this path.

### Terminated process and cold-start Accept

Android can deliver a native Accept before the normal Dart CallKit listener is attached. The frontend therefore treats the incoming payload and the native action as separate durable records:

```text
pending_incoming_call_payload
pending_callkit_action
```

Startup order is intentional:

```text
Widgets binding
→ early CallKit action capture
→ Firebase/bootstrap
→ authenticated push initialization
→ inspect native activeCalls accepted state
→ recover pending native action
→ process terminated incoming push only when no action is pending
→ recover untouched incoming payload only when neither path handled it
```

A pending native action supersedes the original incoming payload. The payload is cleared before action dispatch so the same call cannot be presented and rung again during recovery.

Actions are idempotent:

- handled action signatures are retained for seven days;
- unresolved actions are retained for a later authenticated startup;
- actions older than five minutes are discarded with their stale incoming payload;
- backend status is revalidated before applying the action.

### Stale background message protection

The backend answer window is 30 seconds. The background handler compares `RemoteMessage.sentTime` with device receipt time and rejects an incoming message at or beyond that boundary before requesting native CallKit.

`sentTime` can be unavailable. In that case, the foreground/bootstrap path must still use `get_call_status` to reject a terminal call.

### Accept pipeline

The Accept operation now has one coordinator:

```text
native Accept
→ immediately set joiningRoom
→ navigate directly to CallSessionScreen
→ one get_call_status hydration
→ one permission preparation
→ accept_call
→ obtain token if needed
→ LiveKit join with prepared permissions
→ inCall
```

This prevents the Home flash and removes duplicate status and permission work.

### End and timeout

The frontend selects the backend action from the current lifecycle:

- outgoing pre-connection: `cancel_call`;
- incoming pre-connection: `reject_call`;
- ongoing: `end_call`;
- timeout/missed: reconcile canonical backend state.

LiveKit leave, timer cleanup, native CallKit cleanup, and terminal UI updates are best-effort but idempotent.

## Navigation

`CallNavigationListener` is the only owner of Flutter call navigation.

- Incoming ringing stays on native CallKit.
- `outgoingStarting`, `outgoingRinging`, `joiningRoom`, and `inCall` use `CallSessionScreen`.
- Navigation uses `goNamed`, not a delayed push, to avoid duplicate routes and Home flashes.
- Terminal call state returns to the Calls tab only when the current route is the call session.
- The minimized active-call overlay restores the same global call session.

No widget should manually navigate after `accept_call` or a realtime accepted event.

## Media and permissions

`CallMediaService` owns microphone/camera permission preparation.

Audio call:

```text
microphone permission
→ LiveKit connect
→ microphone enabled
→ camera disabled
```

Video call:

```text
microphone + camera permissions
→ LiveKit connect
→ microphone enabled
→ camera enabled
```

The Accept coordinator prepares permissions once and passes `permissionsAlreadyPrepared: true` into LiveKit join. A denied required permission prevents backend acceptance when possible. If backend acceptance has already occurred and media setup fails, the frontend attempts backend cleanup rather than leaving an orphan ongoing call.

The UI exposes mute, speaker, camera enable/disable, camera switch, minimize, end call, and audio-to-video upgrade according to call type and state.

## Push and native presentation

### Token lifecycle

Authenticated startup:

1. inspect/request display permission;
2. attach foreground/opened-app/token-refresh listeners;
3. recover native CallKit action before incoming payload;
4. obtain the FCM token independently of display permission;
5. register device type, token, and device ID with the backend;
6. inspect the backend result and retry bounded failures.

Tokens, SIDs, and LiveKit credentials must never be logged.

### Android configuration

Required call-related permissions include:

- notification permission;
- microphone and camera;
- internet/network state;
- audio routing;
- wake lock;
- foreground services;
- full-screen intent.

Full-screen intent special access is requested only from an explicit Calls UI action. Application startup must not open system settings.

Backend call IDs and native CallKit UUIDs are always stored separately.

### iOS boundary

The current frontend supports the existing FCM/CallKit integration and preserves iOS camera, microphone, background audio, VoIP, and remote-notification configuration.

Guaranteed killed-app VoIP wake-up requires a backend PushKit/VoIP-token registration contract. The current Calls contract does not expose one, so the frontend must not claim deterministic terminated-state iOS delivery.

## Notifications, missed calls, and history

Incoming calls are transient and are not inserted into the persistent notification inbox.

The backend persists missed calls. The callback action:

```text
missed notification
→ canonical caller account ID
→ get_call_status when available
→ recover original audio/video type
→ start a new outgoing call through CallStarterService
```

Call history supports backend filters, grouped details, per-row deletion, and per-user clear history. Initial history and notification loading is deferred until after the first frame to avoid provider mutation during widget mount.

## Logging and diagnostics

Call diagnostics use `appLogger` plus compact `AOS_CALLS` runtime markers. Safe fields include call ID, event/status, duration, route phase, message age, and whether credentials are present. Secrets and full push payloads are excluded.

Important log groups:

```text
[Lifecycle] platform=paused/resumed/...
Realtime call event
FCM foreground/background message received
callkit_early_capture_started
callkit_action_persisted
callkit_pending_action_recovery_started
Incoming call action hydration completed
accept_call completed
LiveKit join started/completed
Call navigation: current → session
```

Recommended capture:

```bash
adb logcat -c
adb logcat -v epoch > aos_calls_full.log
```

Filtered copy:

```bash
grep -Ei "AOS_CALLS|Lifecycle|FCM|FirebaseMessaging|FLTFireMsgReceiver|CallKit|incoming.call|missed.call|LiveKit|Realtime|ActivityManager|AndroidRuntime|flutter" \
  aos_calls_full.log > aos_calls_filtered.log
```

A killed-process test is confirmed by no PID before the call:

```bash
adb shell pidof com.africaonlinestores.app
```

## Automated tests

Focused tests cover:

- CallKit parameter and push-payload mapping;
- backend ID/native UUID separation;
- native active-call snapshot parsing;
- incoming-payload and native-action persistence;
- idempotent pending-action recovery;
- expired background-message rejection;
- immediate `joiningRoom` transition on Accept;
- duplicate Accept suppression;
- one authoritative `get_call_status` hydration;
- one media permission preparation;
- backend cleanup when LiveKit join fails after acceptance;
- LiveKit permission denial behavior;
- source contracts for startup order, navigation ownership, permissions, token registration, and Android native configuration;
- missed-call callback identity/type recovery.

## Device regression checklist

| ID | Scenario | Expected result |
| --- | --- | --- |
| CALL-01 | Foreground incoming | Native CallKit rings immediately; missed status is correct when unanswered |
| CALL-02 | Foreground Accept | No Home flash; CallSession shows Connecting until LiveKit joins |
| CALL-03 | Resident background incoming | FCM presents native UI; tap/Accept restores one call session |
| CALL-04 | Terminated incoming | CallKit appears before the 30-second answer window expires |
| CALL-05 | Terminated Accept | Persisted/native accepted action is recovered; call is not shown ringing again |
| CALL-06 | Delayed incoming payload | Payload at or beyond 30 seconds does not ring |
| CALL-07 | Duplicate Accept tap/event | One status request and one backend accept action |
| CALL-08 | Permission denied | Clear error; no invalid media join; backend call is reconciled |
| CALL-09 | App background/resume during call | Media continues or reconnects deterministically; one call route remains |
| CALL-10 | End from either participant | Both sides leave LiveKit and native UI closes once |
| CALL-11 | Missed Call Back | New call starts with canonical recipient and recovered type |
| CALL-12 | Small/landscape/200%/RTL | Controls remain reachable with no overflow or clipped actions |

## Known limitations and follow-up risks

1. The backend currently sends an incoming call with a notification block plus data. Android may display a system notification in addition to the native CallKit surface. A deterministic single-surface killed-app contract normally requires a backend-aligned data-only/native delivery strategy.
2. `flutter_callkit_incoming` remains on the locked 3.0.0 baseline. This implementation uses the available event stream, early listener, persisted actions, and `activeCalls()` accepted-state fallback without upgrading the package.
3. Native Accept has a recoverable snapshot fallback. A native Decline that is never replayed by the platform cannot be inferred solely from an absent active call; backend status remains authoritative.
4. Global realtime reconnect behavior is shared by Calls, Chat, Live, and Notifications. It was not paused solely for Calls because that could regress other features. Background DNS retry noise remains a cross-cutting realtime hardening item.
5. Android OEM battery and notification policies can delay background engine startup. Logs must distinguish FCM receipt, Dart handler start, CallKit request, and backend timeout.

## Validation commands

Run from the complete frontend project after applying this ZIP:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/connect/calls
flutter build apk --debug
```

The update contains Dart, tests, and documentation only. It does not change dependencies or native project files.

## Delivery classification

**Shorebird OTA candidate.**

A store release is still appropriate when bundling this with earlier native Calls changes or other Android/iOS configuration changes.
