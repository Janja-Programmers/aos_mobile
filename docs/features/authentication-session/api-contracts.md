# API Contracts

All endpoint identifiers are declared in `ApiEndpoints`. `AuthApi` unwraps Frappe's outer `message` envelope before returning payloads to the controller.

## Password login

| Field | Value |
| --- | --- |
| Frontend method | `AuthApi.login` |
| HTTP method | POST |
| Endpoint | `/api/method/aos.api.v1.auth.login` |
| Authentication | Guest |
| Request | `identifier`, `password`, `client_type: mobile` |
| Response used | `ok`, `data.session.sid`, optional `data.session.authenticated`, optional `data.session.expires_at`, `data.user`, `data.preferences`, `data.roles`, `data.seller` |
| Storage effects | clears previous local SID/cookie before request; on valid success stores nested SID and installs cookie |
| State effects | emits `AuthAuthenticated` after SID and non-empty user validation |
| Errors | stable `error`, especially `INVALID_CREDENTIALS`, account status errors, transport failures |
| Navigation | `LoginScreen` opens preserved redirect or `/` after success |

Exact body:

```json
{
  "identifier": "user@example.com",
  "password": "password",
  "client_type": "mobile"
}
```

Legacy `email`, `usr`, and `pwd` are not serialized.

## Current user

| Field | Value |
| --- | --- |
| Frontend method | `AuthApi.me` |
| HTTP method | GET |
| Endpoint | `/api/method/aos.api.v1.auth.me` |
| Authentication | SID cookie required |
| Request | none |
| Response used | `ok`, `data.user`, `data.preferences`, `data.roles`, `data.seller` |
| Storage effects | none directly |
| State effects | validates restoration or refresh; existing stored SID remains the session identifier |
| Errors | 401/auth-required clears session; network failures are treated as transient |
| Navigation | auth state refresh may redirect protected routes to login |

`/me` is not expected to return SID. A non-empty user object is required before authenticated restoration.

## Logout

| Field | Value |
| --- | --- |
| Frontend method | `AuthApi.logout` |
| HTTP method | POST |
| Endpoint | `/api/method/aos.api.v1.auth.logout` |
| Authentication | optional/current SID |
| Request | no body |
| Response used | ignored for cleanup policy |
| Storage effects | SID and cookie always cleared locally |
| State effects | `AuthGuest` always emitted |
| Errors | server-expired, network, and malformed responses do not prevent local cleanup |
| Navigation | router redirects protected current locations to login |

## Google login

| Field | Value |
| --- | --- |
| Frontend method | `AuthApi.googleLogin` |
| HTTP method | POST |
| Endpoint | `/api/method/aos.api.v1.auth.google_login` |
| Authentication | Guest; Google platform token first |
| Request | `id_token`, `client_type: mobile`, `country`, `language`, `currency` |
| Response | same session/user shape consumed by password login |
| Platform boundary | `GoogleAuthService.signInAndGetIdToken()` |

## Apple login

| Field | Value |
| --- | --- |
| Frontend method | `AuthApi.appleLogin` |
| HTTP method | POST |
| Endpoint | `/api/method/aos.api.v1.auth.apple_login` |
| Authentication | Guest; Apple platform token first |
| Request | `id_token`, `client_type: mobile`, `country`, `language`, `currency` |
| Response | same session/user shape consumed by password login |
| Platform boundary | `AppleAuthService.signIn()` |

The isolated suite tests backend exchange requests, not real provider SDK dialogs.

## Registration

| Field | Value |
| --- | --- |
| Frontend method | `AuthApi.register` |
| HTTP method | POST |
| Endpoint | `/api/method/aos.api.v1.auth.register` |
| Authentication | Guest |
| Request | `email`, `password`, `full_name`, `country`, `language`, `currency` |
| Response used | `ok`, `message` |
| Navigation | successful registration opens email OTP verification |

The current frontend registration request does not include `client_type`; this document does not infer a backend requirement not represented in code.

## Email OTP

| Operation | Endpoint | Request | Result used |
| --- | --- | --- | --- |
| Verify registration email | `/api/method/aos.api.v1.auth.verify_email_otp` | `email`, `otp` | `ok`, `message` |
| Resend registration email OTP | `/api/method/aos.api.v1.auth.resend_email_otp` | `email` | `ok`, `message` |

After successful email verification, the screen calls logout and returns to login with the email query parameter.

## Forgot password

| Operation | Endpoint | Request | Result used |
| --- | --- | --- | --- |
| Request OTP | `/api/method/aos.api.v1.auth.forgot_password_request` | `email` | `ok`, `message` |
| Verify OTP | `/api/method/aos.api.v1.auth.forgot_password_verify_otp` | `email`, `otp` | `data.reset_token` |
| Reset password | `/api/method/aos.api.v1.auth.forgot_password_reset` | `email`, `reset_token`, `new_password`, `confirm_password` | `ok`, `message` |

## Change password

| Field | Value |
| --- | --- |
| Frontend method | `AuthApi.changePassword` |
| HTTP method | POST |
| Endpoint | `/api/method/aos.api.v1.auth.change_password` |
| Authentication | Required |
| Request | `current_password`, `new_password`, `confirm_password` |
| Response | `ok`, `message` |

The UI is located under Account.

## Account deletion and restoration boundary

`AccountLifecycleApi` consumes:

- `/api/method/aos.api.v1.auth.delete_account`
- `/api/method/aos.api.v1.auth.request_restore_account`
- `/api/method/aos.api.v1.auth.restore_account`

These operations are authentication-adjacent but implemented under `features/account`. They are indexed here for boundary clarity and deferred to the Account and Profile feature test phase.
