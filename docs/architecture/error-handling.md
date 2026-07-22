# Error Handling

## Global framework errors

Startup configures:

- `FlutterError.onError` to present Flutter errors;
- `PlatformDispatcher.instance.onError` as a final framework/platform error hook;
- `ErrorWidget.builder` to render `AppErrorFallback`;
- `runZonedGuarded` to log uncaught asynchronous errors through `appLogger`.

These hooks prevent raw framework failure screens from becoming the only user experience, but they do not replace feature-level error states.

## Transport failures

`mapDioException` maps timeout, network, cancellation, HTTP, malformed Frappe server messages, and unknown failures into `Failure`. Important status mappings include 401, 403, 404, 429, 417, and 5xx.

Machine-readable backend `error` values are normalized to uppercase. Auth-related mappings include invalid credentials, auth required, invalid session, disabled/deleted/suspended accounts, unverified email, rate limiting, and validation errors.

## Parsing failures

`unwrapFrappe` returns a parse failure for unsupported response shapes. Feature parsers frequently use shared JSON coercion helpers to tolerate nullable or stringified values. Malformed input must result in a controlled failure or documented fallback, never an uncaught cast.

## UI responsibility

Controllers and screens should expose or render distinct loading, empty, failure, retry, validation, and success states. User-facing messages may derive from `Failure.message`, while programmatic decisions should use `Failure.error`, `Failure.type`, or explicit state.

## Logging

Logging must exclude SID values, tokens, credentials, private messages, document numbers, upload signatures, and sensitive payloads. Existing diagnostic logs that include raw response data should be reviewed during the relevant feature phase before production release.
