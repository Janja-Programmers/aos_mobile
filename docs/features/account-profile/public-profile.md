# Public Profile

## Entry and loading

Public profile is opened with `AppRoutes.nProfile` plus a `user` query parameter. Optional display-name/avatar parameters are presentation fallbacks only. The loader always calls backend `get_profile(target_user)` and verifies that the response `user` matches the requested identifier.

## Public fields

The Flutter view consumes fields actually emitted by the account serializer: public identity, bio, avatar, verification, live state, aggregate counts, relationship state, and block/deletion state. Owner-only email is not rendered.

Seller and Shorts integrations are loaded only when the profile is neither deleted nor blocked. Seller state is a minimal public lookup used to decide whether a storefront button may be displayed.

## Visitor actions

A normal public profile may expose:

- Message through `ChatActions.startChat`
- Follow/Follow Back/Following/Friends through the Social repository
- Seller storefront when a valid seller snapshot exists
- live-room navigation when `live_id` is present
- safety/report/block sheet

The frontend hides actions for deleted or blocked profiles, but backend authorization remains authoritative.

## Connection counts

Counts are taken directly from the profile serializer. Backend `get_followers`, `get_following`, and `get_friends` currently describe only the authenticated user's lists and accept no target-user argument. Therefore public-profile stats are deliberately not tappable and list endpoints are not used to derive another user's totals.

## Unavailable profiles

Backend `PROFILE_UNAVAILABLE`, not-found, malformed, and target-mismatch responses produce an error page with retry. They do not degrade into an interactive fallback profile.

## Public tab privacy

Public visitors see Posts and Reposted. Private, Saved, and Liked are excluded by tab filtering. Deleted/blocked profiles load no content panels.
