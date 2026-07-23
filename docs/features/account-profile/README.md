# Account and Profile

## Purpose

Account and Profile are related but distinct frontend responsibilities:

- **Account** presents the signed-in user's account summary, verification entry point, settings, account-lifecycle actions, and links into marketplace features.
- **Profile** presents either the authenticated user's own public identity or another user's backend-serialized public profile, relationship state, live/seller integration, and profile content tabs.

The authentication/session feature remains authoritative for identity, session validity, roles, preferences, and logout. This feature consumes that state; it does not create a second session abstraction.

## Boundaries

| Concept | Owner in the frontend | Account/Profile usage |
| --- | --- | --- |
| Authenticated identity and SID | Authentication/Session | Determines current user and guest handling |
| Current account profile | `accountsControllerProvider` | Account header and refreshable owner snapshot |
| Own/public profile | `_profileViewDataProvider` in `ProfileScreen` | Profile presentation and integration state |
| Relationship state | Social API/repository | Follow button label and mutation |
| Seller snapshot | Seller endpoint | Public-profile storefront integration only |
| Profile content | Shorts endpoints | Tabs only; Shorts behavior is out of scope |
| Verification | Verification providers/routes | Banner visibility and route entry only |

## Principal entry points

- `AppRoutes.nAccount` → `AccountScreen`
- `AppRoutes.nProfile` → `ProfileScreen`; optional `user`, `display_name`, and `avatar` query parameters
- Account header edit action → own profile
- User cards/search/chat/seller surfaces → public profile through `SocialNavigation.toProfileScreen`
- Account verification banner → verification choice sheet
- Account actions → delete/restore account, preferences, password/security, listings, storefront, and wishlist

## Critical rules

1. A backend profile response, not a locally stored identifier, is authoritative for profile fields and relationship state.
2. Own-profile controls are shown only after a case-insensitive stable user identifier comparison.
3. Public profiles do not render the owner-only email field, avatar-edit affordance, edit action, or private/saved/liked tabs.
4. Deleted or blocked profiles are non-interactive in Profile UI.
5. Relationship labels preserve backend values, including `Friends`; UI text is not used to infer state.
6. Public connection totals come from the profile serializer. Backend connection-list endpoints are current-user-only, so public totals are not recomputed from those lists.
7. Hiding a Flutter action is usability/privacy defense-in-depth. Backend authorization remains the security boundary.

## Documentation index

- [Architecture](architecture.md)
- [Account screen](account-screen.md)
- [Own profile](own-profile.md)
- [Public profile](public-profile.md)
- [Profile editing](profile-editing.md)
- [Avatar and media](avatar-and-media.md)
- [Relationships](relationships.md)
- [Privacy and visibility](privacy-and-visibility.md)
- [State and data flow](state-and-data-flow.md)
- [Navigation](navigation.md)
- [API contracts](api-contracts.md)
- [Error handling](error-handling.md)
- [Testing](testing.md)
- [Maintenance notes](maintenance-notes.md)

Tests live under `test/features/account_profile/` and reuse the shared helpers plus Authentication/Session infrastructure.
