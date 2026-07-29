# Authentication and Session

## State model

Authentication is represented by the sealed `AuthState` hierarchy:

- `AuthLoading` before storage inspection;
- `AuthRestoring` while a stored SID is being validated;
- `AuthRestorationFailure` when validation is temporarily unavailable and may be retried without clearing the SID;
- `AuthGuest` only when no stored session exists or the backend confirms invalidation;
- `AuthAuthenticated` containing `AuthUser`, SID, preferences, roles, and seller summary.

`AuthUser.fromMap` supports compatible identity-verification field names and defensive boolean coercion. This compatibility behavior should be protected by authentication feature tests.

## API contract represented by the frontend

The mobile login request uses:

```json
{
  "identifier": "...",
  "password": "...",
  "client_type": "mobile"
}
```

Google and Apple login requests also include `client_type: mobile` plus optional country, language, and currency values. The authentication controller is responsible for extracting session data, persisting it, setting the API cookie, loading current-user state, and synchronizing preferences.

## Persistence

`SessionStorage` stores SID in `FlutterSecureStorage`. Remember-me and remembered email values are stored in `SharedPreferences`. These data classes have different sensitivity and must remain separated.

## Expiry and cleanup

The API client emits a session-expired event on HTTP 401. Authentication logic performs one `/me` refresh and clears local state only when a stable backend error identifier confirms session or account invalidation. A transient refresh failure preserves the authenticated session. Logout clears local auth/session state regardless of the remote logout outcome.

Cold-start restoration uses request deduplication and operation generations so duplicate or stale responses cannot overwrite logout or a newer account operation. Retryable restoration remains on `/splash`; neither login nor authenticated content is rendered until the session is resolved.

At the application root:

- authenticated state connects realtime using base URL, site name, SID, and email;
- push notification initialization and initial notification loading are attempted;
- guest state disconnects realtime and resets push-notification state.

## Navigation interaction

Protected route access by a guest redirects to login and preserves the attempted URI in a `redirect` query parameter. Authenticated access to login/register/OTP/reset routes redirects home.

## Trust boundary

Frontend route guards and visibility conditions are user-experience controls only. Every protected API must enforce server-side authentication and authorization. Tests should verify frontend behavior without treating it as a security boundary.

## App-lock preparation

See [Native app-lock prerequisites](app-lock-prerequisites.md) for lifecycle, privacy-cover, and typed protected-navigation ownership. Native app lock is not implemented in this iteration.
