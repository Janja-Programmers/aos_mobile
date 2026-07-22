# Authentication and Session

## Purpose

This feature establishes a mobile identity session for Africa Online Stores (AOS), restores that session at application startup, exposes authenticated user context to Riverpod consumers, and removes local authentication state when the session becomes invalid or the user logs out.

Authentication is implemented under `lib/features/auth/`, but the complete boundary also includes `core/api`, secure storage, application bootstrap, route guards, preference synchronization, realtime startup, push-notification startup, and auth-aware feature providers.

## Scope

The phase covers:

- password login using an email or phone identifier;
- Google and Apple identity-token exchange;
- registration and email OTP verification;
- forgot-password OTP and reset-token flows;
- current-user `/me` hydration;
- secure SID storage and cookie installation;
- remembered identifier and remember-me preferences;
- session restoration and expiry handling;
- logout and guest-state cleanup;
- authentication route redirects and protected-route checks.

Account deletion and account restoration use authentication endpoints, but their screens and API wrapper live under `features/account`; detailed behavioral coverage belongs to the Account and Profile phase. Seller profile management, identity verification, and role-based backend authorization are also outside this feature's mutation scope.

## Identity concepts

| Concept | Source | Meaning |
| --- | --- | --- |
| Authentication identity | `AuthUser` | Minimal user identity mapped from login or `/me`. |
| Authenticated session | `AuthAuthenticated` plus stored SID | Server session accepted after a valid login payload or successful `/me` probe. |
| Current-user profile state | `AuthUser`, account providers | User-facing account data; `/me` does not supply SID. |
| Seller state | `AuthSellerSummary` | Login or `/me` seller snapshot, not the complete storefront model. |
| Remembered login preference | `SessionStorage` + SharedPreferences | Whether an identifier should be prefilled. It is not authentication proof. |
| Authorization roles | `AuthAuthenticated.roles` | Backend-provided role names available to frontend consumers. Server authorization remains authoritative. |

A locally stored SID is only a restoration candidate. The controller calls `/me` before emitting `AuthAuthenticated`.

## Entry points

- `/login`
- `/register`
- `/verify-otp`
- `/forgot-password`
- `/reset-password`
- protected-route redirects with `?redirect=<encoded URI>`
- login-required bottom sheets through `AppNavigation`
- application startup through `authControllerProvider` initialization
- centralized HTTP 401 events from `ApiClient.sessionExpiredStream`
- account-screen logout
- email verification completion, which calls logout before returning to login

## High-level architecture

```text
Screen or startup
  -> AuthController
  -> AuthApi
  -> ApiClient / Dio / cookie jar
  -> backend
  -> Failure or Frappe payload
  -> AuthSessionPayload
  -> secure SID + cookie
  -> AuthAuthenticated
  -> router, realtime, notifications, auth-aware providers
```

There is no separate authentication repository layer in the current frontend. `AuthController` depends directly on `AuthApi`.

## Critical business rules

1. Password login sends `identifier`, `password`, and `client_type: mobile` only.
2. Google and Apple backend exchanges include `client_type: mobile`.
3. Login SID is read from `data.session.sid`; legacy top-level SID is ignored.
4. `/me` is current-user state only and is not expected to return SID.
5. `INVALID_CREDENTIALS` produces the same generic UI message for an unknown account and a wrong password.
6. An explicit `data.session.authenticated: false` cannot produce authenticated state.
7. Stored SID is validated through `/me` before session restoration.
8. Logout always clears local SID, cookies, and auth state, even when the server session is already invalid or the request fails.
9. Passwords are never persisted by `SessionStorage`.
10. Protected routes preserve the requested URI in the login redirect query.

## Documents

- [Architecture](architecture.md)
- [API contracts](api-contracts.md)
- [Authentication flows](authentication-flows.md)
- [Session lifecycle](session-lifecycle.md)
- [State and data flow](state-and-data-flow.md)
- [Navigation and route guards](navigation-and-route-guards.md)
- [Storage and security](storage-and-security.md)
- [Error handling](error-handling.md)
- [Testing](testing.md)
- [Maintenance notes](maintenance-notes.md)

## Primary tests

- `test/features/authentication_session/data/models/mobile_login_request_test.dart`
- `test/features/authentication_session/data/models/auth_session_payload_test.dart`
- `test/features/authentication_session/data/api/auth_api_test.dart`
- `test/features/authentication_session/application/controllers/auth_controller_login_test.dart`
- `test/features/authentication_session/application/controllers/auth_controller_session_test.dart`
- `test/features/authentication_session/navigation/auth_navigation_test.dart`
- `test/features/authentication_session/presentation/forms/login_screen_test.dart`
- `test/features/authentication_session/regression/auth_contract_regression_test.dart`
