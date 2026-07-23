# API Contracts

All responses use the shared Frappe envelope unwrapping. Backend paths listed here were inspected as the functional source of truth.

## Profile

| Operation | Method / endpoint | Auth | Request | Parsed response / state effect |
| --- | --- | --- | --- | --- |
| Get own profile | GET `aos.api.v1.accounts.get_profile` | Required | no target | serializer fields into account/profile state |
| Get public profile | GET same endpoint | Required | optional `target_user` | public-safe serializer plus relationship/block state |
| Update profile | POST `aos.api.v1.accounts.update_profile` | Required | any of `full_name`, `bio`, `user_image`, `profile_image_media` | updated profile data; auth/profile refresh |

Aliases accepted by backend for uploaded profile media are `user_image_media`, `profile_image_media`, and `media_id`; Flutter emits canonical `profile_image_media`.

Validation: full name 2–80, bio maximum 300, and a valid media record is required to assign a new uploaded profile image. Profile errors include `NOT_FOUND`, `PROFILE_NOT_FOUND`, and `PROFILE_UNAVAILABLE`.

### Serializer fields consumed

`user`, `full_name`, owner-only `email`, `bio`, `user_image`, profile media identifiers, deletion/live fields, raw/display counts, verification fields, `can_edit`, relationship booleans/status/label, and block fields.

## Social

| Operation | Method / endpoint | Request | Pagination / response |
| --- | --- | --- | --- |
| Relationship status | GET `aos.api.v1.social.get_relationship_status` | query `target_user` | relationship payload |
| Toggle follow | POST `aos.api.v1.social.toggle_follow` | body `target_user` | relationship and current/target count snapshot |
| Followers | GET `aos.api.v1.social.get_followers` | `limit`, `start`, optional `search` | current user's page |
| Following | GET `aos.api.v1.social.get_following` | same | current user's page |
| Friends | GET `aos.api.v1.social.get_friends` | same | current user's page |

List response fields: `items`, `total`, `total_display`, `limit`, `start`, `search`, `has_more`. Maximum limit is 50. Search length is 2–80 when supplied. The backend does not accept a target-user selector for these lists.

## Delete and restore

| Operation | Method / endpoint | Auth | Request | Important behavior |
| --- | --- | --- | --- | --- |
| Delete | POST `aos.api.v1.auth.delete_account` | Required | `confirmation` exactly `DELETE`, optional `reason` max 300 | soft deletion, user disabled/hidden, 30-day restore window, idempotent already-deleted handling |
| Request restore | POST `aos.api.v1.auth.request_restore_account` | Guest | `email` | generic anti-enumeration message |
| Restore | POST `aos.api.v1.auth.restore_account` | Guest | `email`, `otp` | restores eligible soft-deleted account; errors include `OTP_INVALID`, `ACCOUNT_NOT_DELETED`, `RESTORE_EXPIRED` |

## Rate limits discovered

- Get profile: 60 per minute per user.
- Update profile: 20 per minute per user.
- Social operations use backend constants and decorators; frontend must not rely on UI guards as rate-limit enforcement.

## Backend capability boundaries

Block/unblock/list-blocked APIs exist and are integrated through the safety feature, not implemented comprehensively here. Verification, seller, Shorts, and media endpoints are documented only at their Account/Profile integration boundary.
