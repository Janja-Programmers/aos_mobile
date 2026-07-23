# Account Screen

## Composition

`AccountScreen` reads the authenticated state first. Guests receive `AccountGuestHeaderCard`; authenticated users receive `AccountHeaderCard` populated from the account profile response with Authentication/Session fields as fallbacks.

Authenticated actions currently integrate with:

- My Listings
- My Storefront
- My Wishlist
- Password and Security
- Preferences
- Delete Account
- Restore Account
- Verification
- Logout

Privacy policy, terms, and theme selection remain available according to the existing screen logic.

## Data precedence

For the authenticated header:

1. profile `full_name`, `email`, and image aliases,
2. authenticated user fields,
3. localized fallback title.

The backend serializer returns owner email only for self. `AccountScreen` is an owner context, but it still uses authenticated data as a defensive fallback.

## Verification banner

The banner is rendered only when the combined account state is not verified. Verification is considered confirmed by the authenticated user flag, profile `is_verified`, individual verification status, or seller verification status according to `_isAccountVerified`.

- Verified: the banner widget and its preceding spacing are both absent.
- Unverified or pending/rejected: banner presentation is derived from verification providers.
- Tap: opens `VerificationChoiceBottomSheet`.
- Individual: uses `AccountNavigation.toUserVerification`.
- Business: uses the existing seller-verification navigation.

Only visibility and routing belong to this phase. Submission workflows remain in Verification.

## Loading, errors, refresh

`accountsControllerProvider` exposes `AccountState.loading`, `profile`, and `errorMessage`. The screen uses available authenticated values while profile data loads. Pull-to-refresh reloads account and verification-related providers. A profile API failure does not clear the valid authentication session.

## Guest behavior

Guest Account UI provides Login and Sign Up actions and does not read authenticated-only account providers. Protected account actions are absent.

## Logout integration

Logout confirms through the shared confirmation sheet, invokes Authentication/Session logout, and relies on auth-driven provider recreation to clear account state. The Account feature does not persist an independent user session.
