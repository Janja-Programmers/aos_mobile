# AOS Calls Physical Device Test Matrix

Use this matrix after `flutter pub get`, `flutter gen-l10n`, analyzer/tests, and a clean device install. Record **PASS**, **PASS — UPDATE REQUIRED**, **FAIL**, **UNSTABLE**, **BLOCKED**, or **NOT APPLICABLE**.

For every failure capture: device/model, OS/API version, app lifecycle state, call ID, timestamp, sender/receiver role, notification settings screenshot when relevant, and filtered `flutter run`/logcat/Xcode logs around `📞`/CallKit/LiveKit/FCM.

## Android prerequisites

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| AND-P0 | Settings → Apps → AOS → Notifications. Inspect general/call channels. | Notifications enabled for normal release acceptance; call channel not blocked. | BLOCKED | Screenshot all notification/channel states. |
| AND-P1 | Inspect merged release manifest after build. | `USE_FULL_SCREEN_INTENT` absent; no stale `activities.CallkitActivity`; plugin call components/FGS merged; Bluetooth permissions present. | BLOCKED | `merged_manifests/release/AndroidManifest.xml`. |
| AND-P2 | Fresh install on Android 13+. Deny notification permission, then inspect app behavior. | App remains usable; diagnostics explain notification display limitation; no FSI prompt. | BLOCKED | Permission dialog/result + notification drawer/Task Manager screenshots. |

## Android incoming presentation

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| AND-I01 | Keep receiver open/resumed. Place audio call. | Existing Flutter incoming screen appears with localized Answer/Decline; ringtone occurs once; no full-screen system activity. | BLOCKED | Screen recording + call ID + logs. |
| AND-I02 | Repeat AND-I01 with video call. | Flutter video-ringing screen appears; receiver camera does **not** activate before Answer. | BLOCKED | Camera indicator + screen recording + logs. |
| AND-I03 | Foreground incoming call → Answer once. | Exactly one backend accept; direct Connecting/in-call transition; no duplicate page, Home flash, or duplicate permission prompt. | BLOCKED | Screen recording + network/backend call log + Flutter logs. |
| AND-I04 | Foreground incoming call → Decline once. | Exactly one reject; ringing/native notification closes; no app restart. | BLOCKED | Screen recording + backend status + logs. |
| AND-I05 | Background app, unlocked device, call receiver. | Heads-up/shade incoming-call notification with Answer/Decline; no forced full-screen activity. | BLOCKED | Notification screenshot + logs. |
| AND-I06 | Lock receiver, call it. | Lock-screen notification/action surface; no unauthorized full-screen takeover. | BLOCKED | Lock-screen recording + logs. |
| AND-I07 | Swipe receiver app away (do **not** force stop), then call. | Native incoming notification appears while call is actionable. | BLOCKED | Notification + logcat/FCM logs. |
| AND-I08 | From AND-I07 tap Answer. | App opens/recovers once, backend status reconciles, media joins once. | BLOCKED | Screen recording + backend status + logs. |
| AND-I09 | From terminated state repeat call and tap Decline. | Decline reaches backend exactly once; app is not unnecessarily opened by decline. | BLOCKED | Backend status + task/app visibility recording + logs. |
| AND-I10 | Let incoming call ring beyond backend timeout. | Notification/ringing clears as backend becomes missed; stale Accept cannot resurrect it. | BLOCKED | Call ID + backend status + logs. |

## Android stale/offline/retry

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| AND-R01 | Delay/replay an incoming push so device receives it at >=30s from `sentTime`. | No incoming native presentation from that stale push. | BLOCKED | FCM timestamps + logs showing stale rejection. |
| AND-R02 | Test a push without `sentTime` if tooling permits. | Client does not guess stale status; backend reconciliation determines actionability. | BLOCKED | Payload + `get_call_status` trace. |
| AND-R03 | Background incoming notification → disable network → tap Answer → reopen network and resume app before pending action expiry. | Action stays pending during transient failure and retries; it is not falsely marked handled. | BLOCKED | SharedPreferences diagnostic/logs + backend state. |
| AND-R04 | Same as R03 but backend has already ended/missed the call before retry. | Terminal backend state wins; no media join or duplicate lifecycle action. | BLOCKED | Backend status + logs. |
| AND-R05 | Trigger repeated taps on Answer/Decline/end controls. | Duplicate requests are suppressed; one canonical transition occurs. | BLOCKED | API request count + logs. |
| AND-R06 | Simulate lost realtime terminal event while active and wait for status reconciliation. | Client eventually follows backend terminal state and leaves media. | BLOCKED | Backend status + timer/reconciliation logs. |

## Android Bluetooth/audio lifecycle

Run on at least one Android 12/API 31+ device and one Android 14–16 device.

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| AND-B01 | Fresh install, start audio call; grant mic and Bluetooth permissions. | Call joins and handset audio works. | BLOCKED | Permission states + logs. |
| AND-B02 | Pair Bluetooth headset before call, place/answer call. | Audio routes to headset; no forced speaker override. | BLOCKED | Device audio route UI + logs. |
| AND-B03 | During active call disconnect/reconnect Bluetooth headset. | Routing recovers without dropping LiveKit room. | BLOCKED | Recording + audio route/logs. |
| AND-B04 | Deny `BLUETOOTH_CONNECT` but allow microphone. | Call still works on available handset/wired route; Bluetooth limitation is non-fatal. | BLOCKED | Permission state + successful media logs. |
| AND-B05 | Toggle Speaker with Bluetooth attached. | Normal speaker preference does not incorrectly override attached headset unless platform behavior explicitly requires it. | BLOCKED | Route screenshots/recording. |
| AND-B06 | Toggle mute repeatedly. | Microphone state is deterministic; no duplicated permission prompt or media restart. | BLOCKED | UI + remote observation + logs. |
| AND-B07 | Video call → switch camera repeatedly. | Front/back switching works where two cameras exist; no crash on single-camera device. | BLOCKED | Screen recording + logs. |
| AND-B08 | Background an established audio call, then resume. | Audio remains usable under the plugin/FGS path; call state remains synchronized. | BLOCKED | Remote audio verification + logcat. |

## Android permissions and failure states

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| AND-M01 | Deny microphone on audio call. | Call media does not pretend to connect; explicit failure UX/state; no crash. | BLOCKED | Permission screenshot + UI/logs. |
| AND-M02 | Allow mic, deny camera on video call. | Video media path fails explicitly or remains non-video according to existing product behavior; no camera access. | BLOCKED | UI + permission state + logs. |
| AND-M03 | Permanently deny required media permission and retry. | Deterministic error; no request loop/repeated taps race. | BLOCKED | Screen recording + logs. |
| AND-M04 | Slow network during Accept/LiveKit join. | Connecting state remains visible/reachable; stale result cannot override terminal backend event. | BLOCKED | Network shaping + call logs. |
| AND-M05 | Network drops during active call and returns. | LiveKit/repository recovery follows existing reconnect/backend lifecycle; no duplicate room join. | BLOCKED | LiveKit event logs + backend status. |

## Foreground call UI accessibility/responsiveness

Run both audio and video incoming screens.

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| UI-01 | 320px-class small screen, portrait. | Answer/Decline reachable; no RenderFlex overflow/clipping. | BLOCKED | Screenshot + Flutter overflow log. |
| UI-02 | Landscape. | Actions remain reachable; no unsafe-area clipping. | BLOCKED | Screenshot. |
| UI-03 | System text scale 200%. | Labels readable/reachable; no overflow; actions remain tappable. | BLOCKED | Screenshot + overflow log. |
| UI-04 | Arabic locale/RTL. | Correct localized labels and RTL direction; semantics retain correct actions. | BLOCKED | Screenshot + TalkBack output if available. |
| UI-05 | French/Swahili/Chinese locale. | Incoming call labels localized; no clipped actions. | BLOCKED | Screenshots. |
| UI-06 | TalkBack enabled. | Answer and Decline announced as buttons with meaningful labels; no icon-only ambiguity. | BLOCKED | Accessibility recording. |
| UI-07 | Light/dark mode before call. | Call foreground surface remains legible and contrast-safe. | BLOCKED | Screenshots. |

## Outgoing/regression coverage

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| REG-01 | Start audio call from chat. | One `initiate_call`, native outgoing registration preserved, outgoing ringing screen shown. | BLOCKED | API + screen recording. |
| REG-02 | Start video call from chat. | Same as REG-01 with video mode; local outgoing preview only. | BLOCKED | Camera indicator + logs. |
| REG-03 | Receiver accepts. | Caller joins same backend call/LiveKit room; duration starts after connection. | BLOCKED | Both-device recording + backend status. |
| REG-04 | Caller cancels before answer. | `cancel_call`, not `end_call`; receiver stops ringing. | BLOCKED | Backend status + API logs. |
| REG-05 | Receiver rejects. | Caller terminal UI matches rejected state. | BLOCKED | Both-device UI + backend status. |
| REG-06 | Active participant ends. | `end_call`, both clients leave media/native state exactly once. | BLOCKED | Backend status + logs. |
| REG-07 | No answer then Call Again. | Retry uses the hardened outgoing starter/native registration path. | BLOCKED | API + CallKit start logs. |
| REG-08 | Audio→video upgrade request/accept/decline. | Backend-owned upgrade flow preserved; camera only enables after accepted transition/permission. | BLOCKED | Both-device recording + backend logs. |
| REG-09 | Minimize/restore established call. | Same active global state; no second room or timer. | BLOCKED | UI + LiveKit logs. |
| REG-10 | Call history filters/group details/delete/clear. | Existing backend-authoritative history behavior preserved. | BLOCKED | API/UI evidence. |

## iOS real-device matrix

Use a real iPhone. The plugin explicitly warns that incoming CallKit/VoIP behavior is not fully represented by the simulator.

| ID | Steps | Expected | Initial status | Evidence if it fails |
| --- | --- | --- | --- | --- |
| IOS-01 | App visible, receive supported incoming call. | Native CallKit owns incoming ringing; Flutter does not show duplicate incoming page. | BLOCKED | Screen recording + Xcode logs. |
| IOS-02 | Accept native call. | Flutter call session joins once; LiveKit audio becomes available in CallKit activation window. | BLOCKED | Xcode/LiveKit logs + remote audio. |
| IOS-03 | End native/Flutter call. | Room disconnects; audio lifecycle restores cleanly; next media playback/call works. | BLOCKED | Two sequential calls + audio playback evidence. |
| IOS-04 | Speaker/receiver/Bluetooth route tests. | Routing is usable and deterministic; Bluetooth remains preferred when attached unless user explicitly changes route. | BLOCKED | Route UI + logs. |
| IOS-05 | Background active audio call and resume. | Audio background mode sustains supported active-call behavior. | BLOCKED | Remote audio + Xcode logs. |
| IOS-06 | Deny microphone/camera cases. | Required permission errors are explicit; no false in-call media state. | BLOCKED | Permission/UI/logs. |
| IOS-07 | Inspect Release signed entitlements. | Correct production APNs entitlement from signing/provisioning; no assumption based only on source plist. | BLOCKED | `codesign -d --entitlements :- Runner.app`. |
| IOS-08 | Swipe AOS away, then attempt incoming FCM-only call. | **Not a production acceptance requirement for current frontend contract**; reliable VoIP wake is backend-blocked pending PushKit token/delivery support. | NOT APPLICABLE | If observed, record only as exploratory evidence. |

## Build/static acceptance

Run from project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter build apk --debug
```

For store candidate validation:

```bash
flutter build appbundle --release
flutter build ios --release
```

Then inspect the merged Android release manifest and signed iOS entitlements. If `pubspec.lock` changes during `flutter pub get`, commit/ship the solver-generated lockfile rather than a hand-edited hash.

## Minimum device coverage

Before release, obtain passing incoming/outgoing/media results on at least:

- Android 12/API 31;
- Android 13/API 33 notification permission behavior;
- Android 14/API 34 foreground-service/full-screen policy behavior;
- Android 15/API 35;
- Android 16/API 36 target/runtime device when available to your test fleet;
- one Samsung device and at least one non-Samsung Android OEM if AOS production users include both;
- one real iPhone on the minimum supported iOS family and one current iOS device.

Do not mark the feature production-validated solely from emulator tests.
