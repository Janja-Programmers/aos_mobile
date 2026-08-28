# AOS Calls implementation validation

## Scope

This record covers the frontend source hardening for:

- `flutter_callkit_incoming` 3.1.5;
- `livekit_client` 2.10.0;
- Android foreground/background incoming-call presentation without full-screen intent;
- durable native action recovery;
- 30-second stale incoming-push rejection;
- Android Bluetooth permissions/routing preparation;
- LiveKit/CallKit media lifecycle coordination;
- incoming-video camera privacy;
- localization, semantics, large-text and RTL support;
- call-specific tests and documentation.

`backend.zip` was treated as immutable and authoritative. No backend code was changed and no PushKit/VoIP backend capability was invented.

## Static checks performed

The implementation source was checked without invoking Flutter/Dart/CocoaPods. The static pass verified:

- Android manifest and iOS plist XML parse successfully;
- `CallKitLogo.imageset/Contents.json` parses successfully;
- all ARB files parse as JSON;
- English, French, Swahili, Arabic and Chinese ARBs expose the same 528 message keys;
- new call localization getters exist in the generated localization classes;
- exact direct dependency pins are present in `pubspec.yaml`;
- the intended package versions are represented in `pubspec.lock` source entries;
- Android continues to remove `USE_FULL_SCREEN_INTENT` and call source contains no full-screen-permission request;
- Android Bluetooth legacy/API-31+ permissions and optional camera features are declared;
- stale manual CallKit activity declaration is absent;
- iOS background modes contain `audio`, `fetch`, and `remote-notification`, and intentionally omit `voip`;
- microphone/camera usage descriptions and CallKit logo metadata are present;
- the CallKit 3.1.5 background callback is registered;
- 30-second FCM freshness logic is present;
- retry-safe pending native action recovery is wired before pending ringing restoration;
- LiveKit uses external-call-system audio management, engine-availability gating, and `AudioManager` speaker preference;
- incoming video preview is outgoing-only before Answer;
- incoming Answer/Decline controls have localized visible labels and semantics;
- call documentation links to the physical device matrix and this validation record.

Result: **0 static consistency errors**.

Three expected generated-artifact warnings remain until the real toolchains run: missing Pub-generated integrity hashes for the two changed direct packages, and the baseline iOS Podfile lock still recording the prior LiveKit/WebRTC graph.

## Baseline diff review

The final source tree was compared with the supplied `aos.zip` baseline after normalizing line endings for review. Semantic changes are limited to Calls code, Calls tests/documentation, call-specific notification/bootstrap glue, new call localization strings/generated localization accessors, the two dependency pins/transitive graph entries, and the Android/iOS native call configuration/assets required by those changes. No unrelated feature refactor was introduced.

Existing modified text files retain the baseline CRLF convention so the delivered archive does not create whole-file line-ending churn. New call-specific source/test/docs files are additive.

## Toolchain-generated artifacts requiring refresh

Two generated dependency artifacts must be refreshed in the user's Flutter/macOS build environment before release:

1. `pubspec.lock` — the newly selected hosted packages must receive Pub-generated integrity hashes from `flutter pub get`.
2. `ios/Podfile.lock` — the baseline still records the prior LiveKit/WebRTC CocoaPods graph. Run CocoaPods after Pub resolution so it records the native graph selected by LiveKit 2.10.0.

These values are deliberately not fabricated or hand-edited in this source-only environment.

## Required executable validation

Run from the project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter build apk --debug
```

Then on macOS for the iOS dependency graph:

```bash
cd ios
pod install
cd ..
flutter build ios --debug
```

Before release also run the project's normal release builds, inspect the merged release Android manifest, and inspect signed iOS entitlements/provisioning. The Android merged manifest must continue to omit `USE_FULL_SCREEN_INTENT` while retaining the plugin-required foreground-service/notification components.

## Physical acceptance

Automated checks do not replace call-device testing. Execute [`device-test-matrix.md`](device-test-matrix.md), including:

- Android foreground, background, locked and swiped-away incoming calls;
- notification-permission allowed/denied behavior;
- Answer/Decline idempotence and offline retry;
- Bluetooth connect/disconnect/routing during audio and video calls;
- narrow/landscape/200%-text/RTL/TalkBack surfaces;
- real-iPhone foreground/background behavior and CallKit audio activation.

The iOS swipe-away/killed VoIP case remains **BLOCKED** until the backend supports PushKit VoIP-token registration and APNs VoIP delivery.

## Release classification

**Play Store/App Store release required.** Native plugin versions, Android manifest configuration, iOS plist/assets, and the native LiveKit/WebRTC dependency graph changed. This binary baseline is not a Shorebird-only update.
