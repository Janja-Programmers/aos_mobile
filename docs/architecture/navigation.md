# Navigation

## Router composition

`appRouterProvider` in `lib/core/routing/app_router.dart` constructs the application `GoRouter`. Feature route modules contribute route lists for authentication, calls, chats, connect, live, maps, notifications, activity, reviews, search, sellers, social, and Shorts. Marketplace and shell routes are also composed centrally.

`AppRoutes` is the canonical path and route-name registry. New route names and paths must be added there unless the existing feature convention clearly owns constants elsewhere.

## Shell navigation

The application uses root and shell navigator keys. Core marketplace destinations are hosted by `AppShell`, while modal/full-screen workflows can use the root navigator. Navigation tests must assert both the intended location and the returned value when pickers or editor routes pop data.

## Redirect lifecycle

The redirect function reads bootstrap and auth state:

1. before bootstrap readiness, all locations redirect to `/splash`;
2. while auth is loading, restoring, or in a retryable restoration failure, navigation remains on `/splash`;
3. splash redirects to onboarding or home after readiness;
4. incomplete onboarding redirects all non-onboarding routes to onboarding;
5. completed onboarding prevents re-entry to onboarding;
6. guest access to protected prefixes redirects to login with the original URI encoded as `redirect`;
7. authenticated users visiting auth routes redirect home.

The router refresh notifier listens to bootstrap and authentication providers so redirects are reevaluated after state changes.

## Protected route model

`RouteGuards` currently protects configured path prefixes, including seller management, seller location/customization/verification, my ads, connect, create ad, user verification, profile, report-ad, and review creation paths. It strips query strings before comparisons and normalizes dynamic route bases.

This is a frontend navigation guard, not an authorization boundary. Backend authorization remains mandatory.

## Route testing

Use `test/helpers/test_router.dart` for isolated route/widget tests. Full application redirect tests should override bootstrap and auth providers and read `appRouterProvider`. Do not instantiate multiple incompatible router harnesses per feature.


## Notification protected-navigation boundary

Notification taps are parsed into typed, allowlisted destinations before GoRouter is invoked. Canonical identifiers are validated, arbitrary route strings are rejected, and incoming calls remain in the call pipeline. `ProtectedNavigationCoordinator` binds requests to the authenticated account, deduplicates stable request keys, holds at most one pending destination, and clears it on logout, confirmed expiry, or account switching. Its current access policy permits navigation immediately and is intentionally replaceable by the later app-lock gate.
