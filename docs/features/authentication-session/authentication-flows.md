# Authentication Flows

## Password login

```text
LoginScreen loads route prefill or remembered identifier
-> user enters identifier and password
-> Validators.identifier / Validators.passwordRequired
-> UI busy guard disables password and social submissions
-> AuthController controller-level in-flight guard deduplicates rapid calls
-> identifier is trimmed and lowercased
-> prior SID and cookie are cleared
-> AuthApi.login sends identifier/password/client_type
-> Failure is normalized or response is parsed
-> data.session.sid and non-empty data.user are required
-> authenticated:false is rejected
-> SID is installed as cookie and written to secure storage
-> AuthAuthenticated is emitted
-> remember-me and identifier preference are updated
-> preferences synchronize asynchronously
-> router opens redirect target or home
```

### Invalid credentials

```text
backend error INVALID_CREDENTIALS
-> Failure.fromServerPayload reads error
-> authFriendlyMessage returns generic credential text
-> no SID is stored
-> no AuthAuthenticated state is emitted
-> LoginScreen shows generic snackbar
```

Account-existence details in the backend message are not shown when `INVALID_CREDENTIALS` is present.

## Social login

```text
user selects provider
-> GoogleAuthService or AppleAuthService returns identity token
-> cancellation returns a local cancellation Failure
-> prior SID and cookie are cleared
-> AuthApi sends id_token + client_type:mobile + market preferences
-> common _finishAuthResponse validation and hydration
-> AuthAuthenticated
-> router refresh redirects away from auth screen
```

Provider SDKs are static platform boundaries in the current implementation, so isolated tests cover exchange requests and controller response handling rather than invoking native login UI.

## Registration and email verification

```text
RegisterScreen validates legal acceptance, name, email and passwords
-> AuthController.register
-> AuthApi.register
-> success message
-> VerifyOTPScreen(emailVerification)
-> six-digit OTP
-> AuthController.verifyOtp
-> success triggers AuthController.logout
-> success sheet returns to /login?email=<encoded>
```

The OTP screen has a 25-second resend countdown by default and restarts the countdown after a resend tap.

## Forgot password

```text
ForgotPasswordScreen validates email
-> forgot_password_request
-> VerifyOTPScreen(passwordReset)
-> forgot_password_verify_otp
-> data.reset_token required
-> ResetPasswordScreen
-> forgot_password_reset with new and confirm password
-> success sheet
-> /login?email=<encoded>
```

A successful OTP response without `reset_token` becomes a safe failure and does not navigate to reset.

## Session restoration

```text
AuthController.init
-> subscribe once to ApiClient.sessionExpiredStream
-> secure storage getSid
-> no SID: AuthGuest
-> SID: install cookie
-> GET /me
-> non-empty user: AuthAuthenticated using stored SID
-> auth/401/account-disabled error: clear SID/cookie and AuthGuest
-> transport/transient error: AuthGuest while preserving stored SID for a future app retry
```

The current product policy does not expose a dedicated restoration-retry state. A temporary `/me` failure selects guest for this process while leaving the stored SID intact.

## Logout

```text
logout requested
-> POST logout
-> ignore success/failure for local cleanup policy
-> clear secure SID
-> clear cookie jar
-> clear in-flight refresh/login references
-> AuthGuest
-> router and auth-aware providers react
```

Repeated logout calls are safe. The endpoint can be called when the backend session has already expired.

## Session expiry

```text
any Dio response returns HTTP 401
-> ApiClient emits sessionExpiredStream event
-> AuthController ignores event unless currently authenticated
-> one refresh operation is allowed at a time
-> stored SID is read and /me is probed
-> transient failure keeps current authenticated state
-> invalid session clears SID/cookie and emits guest
```

A five-second refresh cooldown suppresses back-to-back completed refresh probes. Concurrent events are also guarded by `_refreshingSession`.
