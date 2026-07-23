# Error Handling

## Mapping

Dio failures are converted by the shared `mapDioException`; successful HTTP envelopes are unwrapped by `unwrapFrappe`. Feature controllers preserve backend `error` identifiers in `Failure` where available and display safe messages.

## Profile failures

- `PROFILE_UNAVAILABLE`: rendered as a non-interactive error state with retry.
- `PROFILE_NOT_FOUND` / `NOT_FOUND`: error state, no fabricated profile.
- malformed/empty data: parse failure.
- target mismatch: parse failure to prevent cross-profile leakage.
- timeout/no connectivity/server error: safe error and retry.
- valid auth remains intact for a profile-only failure.

## Update failures

Client validation stops invalid names/bios before request. Backend validation, transport, and unknown failures end the loading state and keep current form data. Raw server stack traces are never rendered.

## Avatar failures

Picker cancellation is a no-op. Upload failure, blank media ID, profile-update failure, or unexpected exception retains the prior avatar and produces a safe snack message.

## Relationship failures

The existing relationship state/view is retained. The profile button leaves loading, a mapped message is shown, and counts cannot become negative through the defensive model parser.

## Delete/restore failures

Delete requires exact confirmation and constrains reason length. Restore request intentionally uses a generic response to avoid account enumeration. OTP/eligibility/expiry errors are mapped through the standard failure boundary.

## Session expiry

401 and expired-session behavior belongs to Authentication/Session. Account/Profile providers react to guest state and must not independently attempt to preserve a stale authenticated user.
