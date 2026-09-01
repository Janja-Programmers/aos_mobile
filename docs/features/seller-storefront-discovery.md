# Seller storefront discovery and active hours

## Scope

This feature covers seller storefront product discovery and seller operating-hours updates.

Entry points:

- `SellerStorefrontScreen` / `MyStorefrontScreen` -> `SellerProductsSection`
- `StoreCustomizationScreen` -> `OperatingHoursForm` -> seller profile update

The backend remains authoritative for seller identity, public Ads filtering/sorting, operating-hours validation, permissions, and seller update state transitions.

## State ownership and architecture

Seller storefront products reuse the existing Ads discovery owner:

- `AllAdsController`
- `AllAdsState`
- `AdsApi.listAds`
- canonical `AdsSort`

`SellerAdsProvider` is only a seller-scoped `StateNotifierProvider` around `AllAdsController`; it does not implement a second repository, query serializer, pagination engine, or filter model.

The sort/filter bottom sheets are shared with the existing all-ads/wishlist UI through `ads_sort_filter_sheets.dart`.

## Backend contracts

### Seller products

`AdsApi.listAds` sends the seller public/canonical identifier in `seller` and supports the existing public Ads contract:

- sort: `rating_high`, `price_low`, `price_high`, `recent`
- price bounds: `price_min`, `price_max`
- rating bound: `rating_min`
- pagination: `limit`, `offset`

The storefront does not invent `most_reviewed`; the UI uses `Top Rated` -> `rating_high`.

Seller scope is combined with sort/filter values in the same request. The UI does not filter an already-downloaded seller list locally.

### Pagination

The public Ads response currently exposes `pagination.returned` rather than `pagination.has_more`. `AllAdsController` therefore:

1. honors `has_more` if a compatible endpoint provides it;
2. otherwise treats a full page (`returned >= limit`) as potentially having another page;
3. advances offset by returned item count when `next_offset` is absent.

This may produce one final empty request when the total item count is an exact multiple of the page size, but does not hide products beyond the first 20.

### Active hours

`update_my_seller` receives `operating_hours` rows with:

- `day_of_week`: full canonical weekday (`Monday` ... `Sunday`)
- `is_open`: `0` or `1`
- `open_time` / `close_time`: `HH:mm:ss` for open days

`OperatingHoursForm` accepts legacy abbreviated weekdays during hydration (`Mon`, `Tue`, etc.) but always emits the canonical full names required by current backend validation.

## UI states

Seller products explicitly represent:

- initial loading;
- populated results;
- empty filtered results;
- initial request error with retry;
- load-more error while preserving already loaded products;
- load-more progress;
- active sort/filter selection.

Sort/filter sheets are scrollable and use selected semantics so large text and screen readers do not depend only on color.

## Persistence and offline behavior

Sort/filter selection is in-memory screen state owned by the auto-disposed provider. It is not persisted across a destroyed storefront route.

There is no offline seller-products cache in this change. Network failures are surfaced with retry rather than converted to an empty list.

Operating hours persist only after the backend accepts the seller update. Existing seller state reload behavior remains unchanged.

## Security and trust boundaries

- The frontend sends only backend-supported Ads filters and seller IDs.
- Backend seller visibility, permissions, canonical seller resolution, validation and filtering remain authoritative.
- Operating-hours validation remains authoritative on the backend; the frontend only serializes the canonical schema.

## Tests

Relevant coverage added:

- `test/features/sellers/application/operating_hours_form_test.dart`
  - full canonical weekday serialization;
  - closed-day payload shape;
  - legacy abbreviated-day hydration without re-emission.
- `test/features/ads/data/ads_api_seller_discovery_test.dart`
  - seller scope, canonical sort, price/rating filters and pagination are forwarded to `list_ads`.
- `test/features/sellers/application/providers/seller_ads_provider_test.dart`
  - seller-scoped params trim and preserve the seller identifier.

## Validation commands

Run from the project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/sellers/application
flutter test test/features/ads/data/ads_api_seller_discovery_test.dart
flutter test test/features/wishlist/application/all_ads_controller_test.dart
flutter build apk --debug
```

## Release impact

**Shorebird OTA candidate.** The implementation changes Dart code and tests/docs only. It adds no plugin, native permission, SDK/dependency, asset, or storage migration.
