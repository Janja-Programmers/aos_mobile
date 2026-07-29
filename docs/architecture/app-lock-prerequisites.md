# Native App-Lock Prerequisites

## Scope

This foundation prepares authentication, lifecycle, privacy, and protected
navigation for a later native app-lock iteration. It does **not** implement an
app-lock preference, native authentication, lock timing, a lock screen, or a
router security gate.

## Ownership

| Domain | Authoritative frontend owner |
|---|---|
| Backend session and authenticated account | `AuthController` |
| Startup/onboarding bootstrap | `AppBootstrapController` |
| Redirects and route construction | `appRouterProvider` |
| Process visibility | `AppLifecycleController` through `RootLifecycleCoordinator` |
| Background privacy cover | `PrivacyCoverCoordinator` |
| Notification protected destinations | `ProtectedNavigationCoordinator` |
| One pending protected destination | `PendingProtectedNavigationStore` |

The removed `lib/core/session/session_state.dart` model was unused. New features
must use `AuthState`; a second session owner must not be introduced.

## Session restoration

A stored SID starts in `AuthRestoring`. `/me` is used only to validate the
stored backend session and hydrate `data.user`, `data.preferences`,
`data.roles`, and `data.seller`; it does not supply or replace the SID.

Only stable backend invalidation identifiers clear the stored session, including
`SESSION_INVALID`, `AUTH_REQUIRED`, and the supported account-invalid states.
A transport failure, timeout, recoverable server response, an unclassified 401,
or a malformed success payload becomes `AuthRestorationFailure`. The user stays
on an opaque restoration screen and can retry; the SID is preserved until the
backend proves it invalid or the user explicitly logs out.

Restoration and login use operation generations. Duplicate initialization calls
share one future, and stale responses cannot overwrite logout or a newer auth
operation. Logout remains idempotent and local cleanup is authoritative even
when the remote call fails.

## Lifecycle foundation

`RootLifecycleCoordinator` creates one root `AppLifecycleListener` and forwards
normalized states to `AppLifecycleController`.

- `resumed` becomes `foreground`.
- `inactive` remains visible and is treated as an advisory system-overlay or
  interruption state, not as background.
- `hidden`, `paused`, and `detached` protect content.
- Equivalent repeated states are deduplicated.
- The initial binding state records process/startup restoration.

Feature-specific media and call observers may continue when they own local
resource behavior. They must not become competing global visibility owners.

## Privacy cover

Authenticated content receives an opaque Flutter privacy cover when the app is
hidden, paused, or detached. The cover contains only AOS branding and a localized
semantic label. It contains no account or notification data, blocks pointer
input, and excludes protected content from the active semantics tree while
visible.

This Flutter layer is an immediate prerequisite, not complete native snapshot
protection:

- Android product policy must later choose global or sensitive-screen-only
  `FLAG_SECURE`. Global use also blocks screenshots and some screen-sharing or
  support workflows, so it was not enabled without approval.
- iOS must later install an opaque native overlay from the existing lifecycle
  configuration before the app-switcher snapshot is captured. The later app-lock
  implementation must inspect `ios/Runner/AppDelegate.swift` and any adopted
  `UIScene` configuration.

## Protected notification navigation

Notification payloads are parsed into `ProtectedNavigationDestination` values.
Only supported destination kinds and validated canonical identifiers are
accepted. External URLs, protocol-relative paths, traversal paths, and arbitrary
internal route strings are rejected.

`ProtectedNavigationCoordinator` binds requests to the authenticated account,
keeps at most one pending destination, deduplicates deterministic request keys,
and executes exactly once through one `ProtectedNavigationExecutor`. Logout,
confirmed session expiry, and account switching clear pending and deduplication
state. The current access policy always permits navigation; the later app-lock
gate can replace that policy without changing payload parsing.

Incoming-call navigation remains owned by the existing call pipeline.

## Storage and logging

Locked package versions verified from `pubspec.lock` include:

- `flutter_secure_storage` 10.3.1
- `shared_preferences` 2.5.5
- `go_router` 17.3.0
- `flutter_riverpod` and `riverpod` 3.3.2
- `dio` 5.9.2
- `firebase_messaging` 16.4.1

The SID remains in `FlutterSecureStorage`. The cookie jar is memory-only.
Remember Me and the remembered email are non-secret convenience preferences in
`SharedPreferences`; passwords and session credentials must never be stored
there. No storage migration is required by this iteration.

Raw API responses, push payloads, notification tokens, session credentials, and
live message payloads must not be written to production logs. Failure logging is
limited to status and stable error identifiers where needed.

## Network-security limitation

The current Android cleartext and iOS arbitrary-load permissions remain broader
than desired. They were not narrowed because the supplied source does not define
an authoritative complete inventory of production, staging, media, realtime,
map, and call hosts. Before changing them, enumerate every required host and
scheme and use release-safe host-specific exceptions where supported.

Relevant later files:

- `android/app/src/main/AndroidManifest.xml`
- Android network security XML under `android/app/src/main/res/xml/`
- `ios/Runner/Info.plist`

## Upgrade and rollback

This iteration adds Dart state and routing foundations, localization assets,
and a production-log hardening change in `ios/Runner/AppDelegate.swift`. It does
not change stored data formats, native APIs, permissions, dependencies, or
backend contracts. Existing valid sessions remain readable. Rolling back
requires no data migration, although the previous false-guest behavior and
sensitive native logging risk would return after rollback.

## Delivery impact

The Dart-only prerequisites are suitable for Shorebird OTA delivery. The iOS
`AppDelegate.swift` logging correction is native source and therefore requires
a new App Store build to take effect. Deliver this iteration as **dual
delivery** when both the Dart and iOS hardening changes are retained.

## Validation

Run:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter build apk --debug
```

Focused suites are documented in
`docs/features/authentication-session/testing.md`.
