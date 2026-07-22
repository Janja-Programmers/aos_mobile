# State and Data Flow

## Provider map

| Provider | Type | Responsibility |
| --- | --- | --- |
| `authApiProvider` | `Provider<AuthApi>` | Authentication HTTP boundary. |
| `sessionStorageProvider` | `Provider<SessionStorage>` | Secure SID and remembered-login storage. |
| `apiClientProvider` | `Provider<ApiClient>` | Dio, cookie jar, context headers, 401 stream. |
| `authControllerProvider` | `StateNotifierProvider<AuthController, AuthState>` | Session initialization, login, social login, logout, recovery, OTP, profile/preference updates. |
| `isAuthenticatedProvider` | `Provider<bool>` | Derived authenticated-state check. |
| `userPreferenceControllerProvider` | state notifier | Local market/language preferences synchronized after authentication. |
| `appRouterProvider` | `Provider<GoRouter>` | Redirects in response to bootstrap and auth state. |

## Login state flow

`LoginScreen` uses local booleans for password, Google, and Apple progress. The controller itself remains `AuthGuest` during a failed or pending login and emits `AuthAuthenticated` only after complete hydration.

The controller now owns a single `_loginInFlight` future. Repeated direct calls during the same request return that future instead of issuing another API mutation.

## Authenticated payload mapping

```text
data.user -> AuthUser
  email: email fallback id
  fullName: full_name
  userImage: user_image
  bio: bio
  verification: several compatibility boolean keys

data.preferences -> Map<String, dynamic>
data.roles -> trimmed List<String>
data.seller -> AuthSellerSummary
stored/nested sid -> AuthAuthenticated.sid
```

Seller parsing defaults to `AuthSellerSummary.empty` when seller data is absent.

## Preference synchronization

After `AuthAuthenticated` is emitted, `_completeLogin` starts preference synchronization without awaiting it:

1. use complete login or `/me` preference values if country, language, and currency are present;
2. otherwise call `UserPreferenceApi.getMyPreferences` up to two times;
3. save normalized values through `UserPreferenceController`.

Authentication remains successful even if preference synchronization fails.

## Profile and preference updates

`setUserFromMap` and `setPreferencesFromMap` update an existing `AuthAuthenticated` state only. They preserve SID, roles, and seller state. These methods allow account/profile screens to keep auth-derived UI synchronized without another login.

## Router refresh

`_RouterRefreshNotifier` listens to `appBootstrapProvider` and `authControllerProvider`. Any change asks GoRouter to reevaluate redirect logic.

## Cross-feature synchronization

- `AppRoot` reacts to authentication for realtime and push lifecycle.
- conversation state reacts to auth changes and clears on guest;
- account, profile, verification, wishlist, ad cards, and navigation read auth state directly;
- server authorization is still enforced by backend endpoints.

## Disposal

`AuthController.dispose` cancels the session-expiry subscription and clears in-flight references. `ApiClient.dispose` closes the broadcast stream. Provider container disposal in tests is mandatory.
