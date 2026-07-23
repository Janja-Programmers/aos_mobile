# Relationships

## Backend state model

The backend establishes exact relationship states:

| `relationship_status` | Meaning | Typical `action_label` |
| --- | --- | --- |
| `none` | Neither user follows the other | `Follow` |
| `following` | Viewer follows target | `Following` |
| `followed_by` | Target follows viewer | `Follow Back` |
| `friends` | Mutual follow | `Friends` |

Self returns action `You`. Blocked contexts may return `Unblock` or `Unavailable` together with block fields. The frontend preserves `Friends`; it does not normalize it to `Following`.

## Fields consumed

`SocialRelationship` and `AccountProfileSnapshot` consume `is_following`, `is_followed_by`, `is_friend`, status/label, counts, and block fields. Interaction is disabled when either user has blocked the other or the target is deleted.

## Endpoints

- `GET aos.api.v1.social.get_relationship_status?target_user=...`
- `POST aos.api.v1.social.toggle_follow` body `{target_user}`

The toggle endpoint is authoritative for the post-mutation relationship and target/current counts. Backend insertion is idempotent for duplicate follow rows.

## Frontend mutation

Profile sets an in-widget loading guard, invokes the Social repository once, shows mapped failure on error, and invalidates profile/account state on success. It does not perform a speculative counter mutation in the Profile screen; therefore rollback is achieved by retaining the previous loaded view when the request fails.

`SocialRelationshipController` also retains its previous map on toggle failure. Counts parsed by `SocialRelationshipModel` are clamped to zero defensively.

## Connection lists

Backend list operations are current-user-only and use `limit`, `start`, and optional `search`. A target-user argument is not sent. Public profile totals are not linked to these screens.

## Security responsibility

Flutter hides disallowed controls. The backend still enforces login, target validity, block rules, self-action rules, rate limits, and mutation permissions.
