# Maintenance Notes

## Safe extension rules

### Adding an auth endpoint

1. add the endpoint constant to `ApiEndpoints`;
2. implement the request in `AuthApi` using existing `ApiClient` methods;
3. return `Either<Failure, Map<String, dynamic>>` and reuse `unwrapFrappe`/`mapDioException`;
4. model stable request or response contracts when they affect session safety;
5. add recording-adapter tests for method, path, exact body, and failures;
6. add controller tests for every state or storage effect.

### Changing login response

Keep parsing centralized in `AuthSessionPayload`. Do not reintroduce top-level SID fallback without an explicit compatibility decision and regression updates. Explicit `authenticated: false`, missing SID, or missing user must remain non-authenticated.

### Adding a social provider

Separate the native provider boundary from backend exchange, include `client_type: mobile` when required, reuse common login response hydration, and expose an injectable platform seam before adding controller tests.

### Adding protected routes

Update `RouteGuards` with the static or dynamic route base, then add both
classification and `authenticationRedirect` decision tests. The application
router delegates its authentication branch to that pure decision. Avoid
substring matching; use normalized path boundaries.

## Defects fixed in this phase

1. Login previously ignored `data.session.authenticated`; a payload containing SID and user with `authenticated: false` could become authenticated.
2. Direct rapid `AuthController.login` calls could issue duplicate requests even though `LoginScreen` had a local busy guard.
3. Login form controls had no stable semantic test keys.
4. Session refresh cooldown used `DateTime.now` directly and was not deterministic in isolated tests.
5. OTP resend reset changed the internal counter but did not immediately rebuild the UI, leaving `Resend` visible until the next timer tick.
6. Authentication fixtures were passed through the foundation's global fixture root, producing invalid paths for feature-local files.
7. The redirect test drove an unmounted `GoRouter`; redirect behavior is now exposed through the pure decision used by the production router.

## Known limitations and risks

### Decentralized cache cleanup

`AuthController` clears SID, cookie, and auth state, but it does not maintain a global list of feature providers to invalidate. Some features listen to `AuthState`; others may retain stale caches until disposed or refreshed. Cross-feature logout cleanup should be audited in the final integration phase.

### Restoration transient failure

A network failure during startup leaves the secure SID stored but emits `AuthGuest`. There is no dedicated retry/unknown state. This can temporarily present a logged-out UI even though the backend session may still be valid.

### Login clears prior SID before request

Password and social login clear prior local SID/cookie before exchanging new credentials. The UI normally prevents authenticated users from visiting auth routes, but direct controller use during an existing session can replace session context before success.

### Static OAuth services

Google and Apple platform services are static/concrete. Backend exchange is testable, but controller-level provider success/cancellation cannot be fully isolated without introducing injectable platform interfaces.

### Route protection coverage

The protected prefix list is selective. Some account routes depend on screen-level checks rather than router protection. New sensitive routes must not assume parent-path protection automatically.

### Router lifecycle

`appRouterProvider` currently returns `GoRouter` without registering `router.dispose` through `ref.onDispose`. Tests dispose routers explicitly. This is a shared routing maintenance item, not changed in this auth-focused phase.

### OTP presentation messages

Some OTP resend and reset branches display `Failure.toString()` or wrap normal messages in an unexpected-error localization. This can produce less polished user text. Correct it in a focused authentication UI follow-up or when the verification/account phase owns those screens.

### Expiry timestamp

`expires_at` is parsed but not used to schedule proactive refresh or logout. Server responses and HTTP 401 remain the source of truth.

## Recommended next feature

Account and Profile should follow because it consumes authenticated identity, profile mutation synchronization, password security, deletion/restoration, preferences, seller snapshot, and logout entry points.
