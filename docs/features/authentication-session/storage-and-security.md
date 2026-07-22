# Storage and Security

## SID persistence

`SessionStorage` writes SID to `FlutterSecureStorage` using key `aos_sid`. The SID is not stored in SharedPreferences.

At runtime, `ApiClient.setSid` also writes the SID into its cookie jar as an HTTP-only cookie named `sid` with path `/`. The cookie jar is in memory, so startup restoration reads secure storage and reinstalls the cookie.

## Remembered identifier

Remember-me and the remembered identifier are separate lightweight preferences:

- `aos_remember_me`
- `aos_email`

The remembered identifier is used only to prefill login. It is not a password, token, session proof, or authorization grant.

When remember-me is false after successful login, the remembered identifier is removed. The default remember-me value is true when no preference exists.

## Password handling

- Password controllers are disposed by their screens.
- `SessionStorage` has no password write or read method.
- password and confirmation values are sent only in relevant POST bodies;
- tests use fake values and do not persist them;
- reports and fixtures must not include real credentials.

The frontend cannot prevent lower networking layers or external debugging tools from observing process memory. Production logging must avoid request bodies and authentication payloads.

## Error privacy

`INVALID_CREDENTIALS` maps to one generic message for wrong-password and unknown-account cases. Stable `error` takes precedence over account-specific backend message text.

Account restoration request fallback text is intentionally non-enumerating, but that API lives under Account and is deferred to the next feature phase.

## Social tokens

Google and Apple identity tokens are passed directly to the backend exchange and are not stored by `SessionStorage`. Tests replace them with fake token strings and do not invoke provider SDKs.

## Test data policy

Fixtures use:

- `user@example.invalid`;
- `fake-password`;
- `test-session-id`;
- `.invalid` service URLs.

No production SID, OAuth secret, cookie, API key, personal email, or staging credential is included.

## Frontend trust boundaries

- local `AuthAuthenticated` controls UI and routing only;
- backend endpoints must enforce authentication and authorization;
- roles and seller status are display/action hints, not permission proof;
- stored SID must be validated through `/me`;
- `expires_at` is not locally authoritative in the current implementation;
- HTTP 401 and stable backend auth errors remain the invalidation source.

## Platform boundaries not covered by isolated tests

- Keychain/Keystore behavior of `FlutterSecureStorage`;
- OS backup/restore and application reinstall behavior;
- native Google and Apple dialogs;
- platform cookie implementation beyond Dio's in-memory cookie jar;
- TLS and certificate policy of deployed endpoints.
