# Authentication and Session

## State model

Authentication is represented by the sealed `AuthState` hierarchy:

- `AuthLoading` during restoration or an in-flight transition;
- `AuthGuest` when no valid session exists;
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

The API client emits a session-expired event on any HTTP 401. Authentication logic subscribes to that event and must clear local session state when the session becomes invalid. Logout is expected to clear local auth/session state regardless of remote logout outcome.

At the application root:

- authenticated state connects realtime using base URL, site name, SID, and email;
- push notification initialization and initial notification loading are attempted;
- guest state disconnects realtime and resets push-notification state.

## Navigation interaction

Protected route access by a guest redirects to login and preserves the attempted URI in a `redirect` query parameter. After authentication, the router is the single navigation owner: it restores a validated internal protected destination or falls back home. Login widgets do not issue a competing success navigation.

## Trust boundary

Frontend route guards and visibility conditions are user-experience controls only. Every protected API must enforce server-side authentication and authorization. Tests should verify frontend behavior without treating it as a security boundary.
