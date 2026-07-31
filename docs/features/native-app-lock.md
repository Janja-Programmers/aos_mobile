# Application lock

## Scope

App lock is an optional local protection layer for private authenticated areas.
A new install has no app-lock configuration and shows no lock prompt. App lock
does not log in to the backend, refresh a session, replace backend authorization,
or change session-expiry behavior.

The configuration entry remains in **Account → Passwords & Security → Security**.
Public marketplace routes remain usable without app lock. Hybrid account content
is treated as private while a valid authenticated session exists.

## Lock methods

A signed-in user can configure one of three methods:

- a four-digit AOS PIN;
- a 3×3 AOS pattern containing at least four unique points;
- fingerprint, Face ID, or another biometric already enrolled with the device.

Raw PINs and patterns are never persisted or logged. They are normalized and
stored through `FlutterSecureStorage` only as PBKDF2-HMAC-SHA256 salted hashes.
Hash derivation runs in a separate Dart isolate. Biometric templates never enter
AOS and remain owned by Android or iOS. `local_auth` is invoked with
`biometricOnly: true` for the biometric method.

The previous OS-authentication-only preference format is migrated to the
biometric method. Legacy one-minute and five-minute timings migrate to 30
seconds, the longest timing in the current product contract.

## Ownership and runtime state

`AppLockController` is the only app-lock state owner. Configuration is scoped to
the normalized authenticated account identifier. The following remain
memory-only:

- unlocked/locked runtime state;
- background timestamp;
- active native prompt state;
- in-flight local verification;
- operation generation.

A process recreation always starts locked when that account has a configuration.
Stale PIN, pattern, or biometric results cannot unlock another account. If the
secure configuration cannot be read, private routes fail closed and the lock
screen offers retry or explicit reset/logout recovery.

Normal backend logout clears runtime lock state but leaves the account-scoped
configuration available for the next login on the same installation. The
explicit **Reset app lock** recovery flow clears both configuration and auth.

## Lifecycle and timing

The available delay choices are:

- immediately;
- 5 seconds;
- 10 seconds;
- 15 seconds;
- 30 seconds.

The root lifecycle coordinator records when AOS becomes hidden or backgrounded.
Elapsed decisions use a monotonic `Stopwatch`. `inactive` alone is not treated as
a true background event. Native biometric prompts are excluded from relocking
loops. Termination or process eviction always results in a locked start when
configured, regardless of the selected background delay.

## Routing and public access

The Flutter root renders the lock screen only for app-lock-protected routes. It
does not place a transparent page over mounted private content. Public routes
continue to render. The account root is treated as private by app lock while a
session exists because it contains identity and account data, but it remains a
public guest screen after logout.

Protected notification destinations remain typed, account-bound, and pending
until the local lock permits access. Logout, session expiry, and account
switching clear stale protected navigation.

## Setup, change, and disable

PIN and pattern setup require confirmation. Patterns may contain four or more
points and are submitted explicitly after drawing or accessible point entry.
Biometric setup requires one successful biometric authentication. Changing or disabling app lock requires
verification with the current configured method. Disabling app lock removes the
local configuration without modifying backend authentication.

All action-label text uses the shared `context.button` typography.

## Forgotten-lock recovery

The lock screen exposes **Reset app lock**. After explicit confirmation it:

1. clears the current account’s local app-lock configuration;
2. invokes the existing idempotent backend logout pipeline;
3. clears local session and authenticated state;
4. clears pending private navigation;
5. returns to the public home experience.

The user must authenticate again before the Passwords & Security entry is
available and a new app lock can be configured. Failed PIN, pattern, or biometric
attempts never log the user out or alter the backend session.

## Native requirements and privacy

Android retains `FlutterFragmentActivity`, `USE_BIOMETRIC`, AppCompat themes,
and the native opaque task-switcher cover. iOS retains
`NSFaceIDUsageDescription` and the native app-switcher privacy overlay. Global
`FLAG_SECURE` remains disabled so screenshots and support screen sharing keep
the existing product behavior.

## Validation

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/app_lock
flutter test test/core/routing
flutter test test/features/notifications/application/services
flutter test
flutter build apk --debug
```

Physical Android and iOS checks remain required for fingerprint/Face ID setup,
biometric cancellation and lockout, power-button/device-lock transitions,
process eviction, every timeout, app-switcher snapshots, TalkBack, and VoiceOver.
