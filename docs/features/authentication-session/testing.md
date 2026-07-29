# Testing

## Scope

The suite protects authentication contracts, defensive payload parsing, storage behavior, controller transitions, provider derivation, login UI behavior, route redirects, OTP cooldown, and historical migration risks.

No test calls a real backend, secure-storage platform channel for SID, or OAuth provider SDK.

## Shared foundation reused

- `createTestContainer`
- `pumpTestApp`
- `setUpTestPreferences`
- `FakeSessionStorage`
- `RecordingHttpClientAdapter`
- JSON fixture loader with an explicit base-directory override for
  feature-local fixtures
- test API base URL and sanitized constants
- foundation route-guard tests

Feature-local helpers only assemble authentication-specific providers and scripted API behavior.

## Test levels

| Behavior | Level | Test location |
| --- | --- | --- |
| exact mobile login body | model/API | `data/models/mobile_login_request_test.dart`, `data/api/auth_api_test.dart` |
| no legacy fields | model/regression | `data/models/mobile_login_request_test.dart`, `regression/auth_contract_regression_test.dart` |
| nested SID and session metadata | model/controller | `data/models/auth_session_payload_test.dart`, `application/controllers/auth_controller_login_test.dart` |
| `/me` without SID | model/controller | `data/models/auth_session_payload_test.dart`, `application/controllers/auth_controller_session_test.dart` |
| stable `error` mapping | API/unit | `data/api/auth_error_mapping_test.dart`, `data/api/auth_api_test.dart` |
| generic invalid credentials | controller/widget | `application/controllers/auth_controller_login_test.dart`, `presentation/forms/login_screen_test.dart` |
| remember-me and identifier | storage/controller/widget | `data/storage/session_storage_test.dart`, controller and form tests |
| restoration | controller/provider | `application/controllers/auth_controller_session_test.dart` |
| idempotent logout cleanup | controller | `application/controllers/auth_controller_session_test.dart` |
| simultaneous HTTP 401 | controller/interceptor | `application/controllers/auth_controller_session_test.dart` |
| auth provider synchronization | provider | `application/providers/auth_providers_test.dart` |
| protected-route redirects | navigation/pure guard | `navigation/auth_navigation_test.dart` |
| form validation and busy guard | widget | `presentation/forms/login_screen_test.dart` |
| OTP resend cooldown | widget | `presentation/forms/otp_resend_row_test.dart` |
| registration/recovery request contracts | API | `data/api/auth_registration_recovery_api_test.dart` |

## Fixtures

Feature fixtures are under `test/features/authentication_session/fixtures/`.
The shared fixture loader now accepts an optional `baseDirectory`, so
authentication tests keep their feature-local fixtures without duplicating or
relocating them into the global `test/fixtures/` tree. They contain only
sanitized identities, tokens, URLs, and session values.

## Network isolation

`RecordingHttpClientAdapter` intercepts every Dio request and returns scripted `ResponseBody` instances or scripted Dio failures. Assertions cover path, method, body, headers, and request count.

`ScriptedAuthApi` isolates controller tests from Dio and records password-login calls. Password values are fake and never printed by test code.

## Provider isolation

`buildAuthControllerHarness` creates one isolated `ProviderContainer`, overrides storage/API/client/bootstrap dependencies, waits for initialization to reach a terminal restoration state. Each test that creates a harness owns and disposes its container.

## Commands

```bash
dart format lib/features/auth test/features/authentication_session
flutter analyze
flutter test test/widget_test.dart test/helpers test/fakes test/core
flutter test test/features/authentication_session
flutter test test/features/authentication_session --coverage
flutter test
```

## Coverage priorities

1. exact request and stable error contracts;
2. nested SID and `/me` separation;
3. login, restoration, expiry, and logout transitions;
4. provider and router synchronization;
5. duplicate mutation prevention;
6. sensitive-message handling.

## Excluded boundaries

- real Keychain/Keystore operations;
- native Google and Apple SDK flows;
- deployed backend integration;
- server-side authorization and session expiry scheduling;
- complete account deletion/restoration flows;
- full realtime and push service integration after auth state changes.


## App-lock prerequisite focused suites

```bash
flutter test test/features/authentication_session/application/controllers/auth_controller_session_test.dart
flutter test test/features/authentication_session/navigation/auth_navigation_test.dart
flutter test test/app/bootstrap/app_bootstrap_controller_test.dart
flutter test test/app/splash/splash_restoration_failure_test.dart
flutter test test/core/lifecycle/app_lifecycle_coordinator_test.dart
flutter test test/core/privacy/privacy_cover_test.dart
flutter test test/core/navigation/protected_navigation_coordinator_test.dart
flutter test test/features/notifications/application/services/notification_destination_parser_test.dart
flutter test test/features/authentication_session/data/storage/session_storage_test.dart
flutter test test/security/sensitive_logging_source_test.dart
```

These suites cover bootstrap restoration, retryable session restoration, stable invalidation, duplicate and stale requests, redirect blocking, lifecycle normalization, privacy-cover opacity and accessibility, notification route validation, exactly-once navigation, account-bound clearing, storage boundaries, and sensitive-log source regression checks.
