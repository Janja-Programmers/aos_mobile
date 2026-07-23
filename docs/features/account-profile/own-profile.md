# Own Profile

## Ownership

`ProfileScreen` resolves the target to the route `user` query value or the authenticated user's email. Ownership is determined by case-insensitive comparison of those stable identifiers. Display name is never used for ownership.

## Owner controls

Own profile exposes:

- Edit Profile
- avatar media choices when not live
- Activity Center entry
- connection-stat navigation
- owner profile tabs: Posts, Private, Reposted, Saved, and Liked
- refresh of profile and account state

Message, Follow, public safety actions, and seller-store visitor actions are not shown for self.

## Live avatar precedence

When the backend profile indicates `is_live` and supplies a non-empty `live_id`, tapping the avatar enters that live room. Live navigation takes precedence over avatar editing. Without an active live room, own-avatar tap opens Upload photo / Take photo.

## Profile statistics

Following, Followers, and Likes are rendered with the shared `humanizeCount` helper. Own connection stats are tappable because backend list endpoints return the current authenticated user's lists. Friends are represented in loaded state but are not currently a visible header stat.

## Content tabs

Tab integration loads Shorts endpoints, but Shorts filtering/paging semantics are owned by the Shorts phase. Profile enforces the important boundary: private, saved, and liked tabs exist only for the owner.

## Synchronization

- Pull-to-refresh invalidates profile and account providers.
- Edit-sheet completion invalidates both.
- Avatar update updates authenticated user data and invalidates both.
- Logout recreates account state and Profile becomes guest-only.
