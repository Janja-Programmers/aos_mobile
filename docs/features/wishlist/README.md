# Wishlist

## Scope

The wishlist feature owns authenticated ad save/remove interactions and the dedicated wishlist listing screen. The backend remains authoritative for membership, filters, pagination, validation, permissions, and rate limits.

## State ownership

- `AOSAdListItem.isWishlisted` and `AOSAdDetails.isWishlisted` are the initial authoritative values returned by backend ad/list/detail endpoints.
- `WishlistController` owns only temporary per-ad overrides created by successful or in-flight user interactions.
- The controller does not eagerly fetch the user's full wishlist and does not persist wishlist IDs locally.
- Authentication changes rebuild the controller and clear account-scoped overrides.
- A pending set prevents duplicate submissions for the same ad.
- Each mutation sends the explicit desired `wishlisted` state. The final backend response replaces the optimistic value.

This avoids a competing local wishlist store, removes an unnecessary startup request, and prevents one account's cached wishlist from leaking into another session.

## Backend contracts

### List wishlist

`GET aos.api.v1.wishlist.list_wishlist`

Frontend-supported parameters:

- `limit`: 1–50; frontend default 20
- `offset`: non-negative
- `sort`: `rating_high`, `price_low`, `price_high`, or `recent`
- `q`: omitted/empty or at least two characters
- `price_min`
- `price_max`
- `rating_min`
- `verified_seller`: `0` or `1`
- market context supplied through the existing API client

The frontend does not send unsupported aliases such as `search`, `verified_sellers`, or `preferred_store`.

The list controller consumes backend `pagination.has_more` and `pagination.next_offset` rather than inferring pagination solely from item count.

### Set wishlist state

`POST aos.api.v1.wishlist.toggle_wishlist`

Body:

```json
{
  "ad_id": "AD-...",
  "wishlisted": 1
}
```

The backend response `data.wishlisted` is authoritative. Sending the desired state makes retries idempotent and avoids accidental double inversion.

## UI behavior

- Guest taps continue through the existing authentication guard.
- Authenticated taps update optimistically.
- Repeated taps for the same ad are disabled while the request is pending.
- Card wishlist actions expose localized semantics and 48×48 logical-pixel touch targets.
- Failures restore the prior resolved state and retain the backend-provided fallback.
- Wishlist controls resolve state from a temporary override first, then the ad payload's `is_wishlisted` value.
- The unsupported “Preferred Store” filter is not shown.
- A one-character search remains local and does not produce a backend validation request; search starts at two characters or after clearing the field.

## Offline and errors

There is no fabricated offline wishlist mutation queue. A failed mutation is rolled back and can be retried by the user. Existing ad content remains visible. The dedicated wishlist screen exposes its normal list error/retry state.

Notification permission denial is an expected device state and is logged at informational level; token registration is deferred until permission becomes available on a later application start or token lifecycle event.

## Tests

- `test/features/wishlist/data/ads_api_wishlist_test.dart`
  - exact list query fields
  - page/search client guards
  - explicit desired mutation state
- `test/features/wishlist/application/wishlist_controller_test.dart`
  - no eager list request
  - optimistic state
  - duplicate-submit prevention
  - rollback
  - backend response authority
  - auth-boundary reset
- `test/features/wishlist/application/all_ads_controller_test.dart`
  - backend pagination metadata
  - one-character search suppression
  - stale-response protection after search/filter changes
- `test/features/wishlist/presentation/ad_card_image_test.dart`
  - backend-state fallback and temporary override precedence
  - localized semantics, large text, and touch-target regression coverage
- `test/features/wishlist/regression/wishlist_contract_regression_test.dart`
  - deleted local cache/eager-fetch architecture
  - unsupported request/filter regression guards

## Validation

Run from the project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/wishlist
flutter test
flutter build apk --debug
```

These commands were not executed in the delivery environment because Flutter and Dart were unavailable. Static source review was performed instead.

## Release classification

**Shorebird OTA candidate.** The implementation changes Dart code, tests, and documentation only. It introduces no native code, plugin, permission, asset, SDK, dependency, or storage migration. Removing the obsolete local wishlist key requires no migration because the value is no longer read and is not security-sensitive; an old unused SharedPreferences entry may remain harmlessly on upgraded devices.

## Known follow-up

The current wishlist filter sheet and some shared marketplace controls contain pre-existing hard-coded strings. They should be moved into the application's localization catalog in a separate UI-localization pass that covers the entire screen consistently rather than translating only the controls touched here.
