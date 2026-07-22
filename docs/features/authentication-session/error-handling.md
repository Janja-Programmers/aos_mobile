# Error Handling

## Error pipeline

```text
DioException or Frappe payload
-> mapDioException / unwrapFrappe
-> Failure.fromServerPayload
-> stable error normalization
-> authFriendlyMessage
-> controller Either<Failure, ...>
-> screen snackbar or navigation branch
```

The stable backend field is `error`. The legacy `code` field is not parsed into `Failure.error`.

## Stable authentication errors

| Error | Failure type | Friendly behavior |
| --- | --- | --- |
| `INVALID_CREDENTIALS` | unauthorized | generic invalid email/phone/password text |
| `AUTH_REQUIRED` | unauthorized | login required |
| `SESSION_INVALID` | unauthorized | login required / invalid restoration |
| `UNAUTHORIZED` | unauthorized | login required |
| `UNAUTHENTICATED` | unauthorized | login required |
| `LOGIN_REQUIRED` | unauthorized | login required |
| `ACCOUNT_DISABLED` | forbidden | contact support |
| `ACCOUNT_DELETED` | forbidden | deleted/unavailable |
| `ACCOUNT_DELETED_RESTORABLE` | forbidden | restore account |
| `ACCOUNT_SUSPENDED` | forbidden | contact support |
| `EMAIL_NOT_VERIFIED` | forbidden | navigate to verification from login |
| `RATE_LIMITED` / `RATE_LIMIT` | rate limited | retry later |
| `VALIDATION_ERROR` | validation | backend fallback or generic check-input text |

## Transport mapping

- connect/send/receive timeout -> `FailureType.timeout`;
- connection error/bad certificate -> `FailureType.network`;
- cancelled request -> unknown type with request-cancelled message;
- HTTP 401 -> unauthorized and session-expiry stream event;
- HTTP 403 -> forbidden;
- HTTP 404 -> not found;
- HTTP 429 -> rate limited;
- HTTP 5xx -> server;
- malformed non-map success envelope -> parse failure.

## Login safeguards

Login does not persist or emit authenticated state when:

- `ok` is not true;
- nested SID is absent;
- user data is absent;
- session explicitly reports `authenticated: false`;
- API returns `Failure`;
- response is malformed.

## Restoration classification

`AuthController._isInvalidSessionFailure` clears local session for:

- any auth-required failure;
- HTTP 401;
- disabled, deleted, restorable-deleted, or suspended account errors.

Other failures are transient during restoration/refresh.

## Unknown errors

When no known stable token exists, the current `Failure` implementation may retain a non-empty backend fallback message. Security-sensitive endpoints should therefore continue to provide stable errors for cases where raw message disclosure would be unsafe.

## UI caveats discovered

Some OTP/resend error branches wrap `Failure.toString()` inside a localized “unexpected error” template instead of using `Failure.message`. This phase does not broadly rewrite OTP presentation, but the behavior is recorded as a maintenance risk.
