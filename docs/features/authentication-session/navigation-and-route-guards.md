# Navigation and Route Guards

## Auth routes

| Name             | Path               | Inputs                                               |
| ---------------- | ------------------ | ---------------------------------------------------- |
| `login`          | `/login`           | query `email`, query `redirect`                      |
| `register`       | `/register`        | none                                                 |
| `verifyOtp`      | `/verify-otp`      | extra String email or Map with `email` and `purpose` |
| `forgotPassword` | `/forgot-password` | none                                                 |
| `resetPassword`  | `/reset-password`  | extra Map with `email`, `reset_token`                |

`RouteGuards.isAuthRoute` removes query data and requires exact path equality. `/login/other` is not classified as an auth route.

## Protected route classification

`RouteGuards.isProtectedRoute` removes query data and checks exact static bases or subpaths. Dynamic patterns such as `/report-ad/:adId` are reduced to their static base.

The protected prefix list currently includes seller-store-related paths, seller location/customization/verification, my ads, connect, ad creation, user verification, profile, report-ad, and create-review bases.

Not every account route is listed as protected. Screens may still enforce authentication internally. This is a real maintenance risk documented in [maintenance notes](maintenance-notes.md).

## Redirect algorithm

The authentication-dependent branch is implemented by the pure
`RouteGuards.authenticationRedirect` decision and is called by
`appRouterProvider` after bootstrap and onboarding checks. This keeps the
production behavior unchanged while allowing redirect preservation and loop
prevention to be tested without mounting unrelated feature screens.

```text
bootstrap not ready -> /splash
auth loading -> /splash
/splash + onboarding incomplete -> /onboarding
/splash + onboarding complete -> /
onboarding incomplete + other route -> /onboarding
onboarding complete + onboarding route -> /
guest + protected route -> /login?redirect=<encoded current URI>
authenticated + login with valid protected redirect -> redirect target
authenticated + other auth route -> /
otherwise -> no redirect
```

The redirect uses `state.uri.toString()`, preserving query parameters in the encoded `redirect` value.

## Login completion

`LoginScreen` updates authentication state only. `GoRouter.redirect` is the
single post-login navigation owner for password and social login. A login
`redirect` query is accepted only when it is an internal, validated protected
route; external URLs, protocol-relative URLs, traversal segments, malformed
URIs, and public-route injection fall back to `/`.

## Logout and expiry

When auth becomes guest while the current URI is protected, router refresh
redirects to login and encodes the current protected URI. Accounts is a public
shell, so its explicit Logout action clears auth and then opens Login once.
The logout callback captures the auth controller before awaiting confirmation,
preventing use of a disposed widget `ref`.

## Guard tests

- static path classification: `test/core/routing/route_guards_test.dart` from the shared foundation;
- auth-specific classification and the same pure redirect decision used by
  `GoRouter`: `test/features/authentication_session/navigation/auth_navigation_test.dart`.

The tests cover dynamic protected routes, guest redirect preservation,
authenticated protected access, guest-only auth routes, and loop avoidance.
