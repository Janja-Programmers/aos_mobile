# Seller location and maps frontend

## Scope

This patch hardens the Flutter seller-location and seller-map surfaces while keeping `aos/main` authoritative for geocoding, supported coverage, seller permissions, canonical seller IDs, route generation, rerouting inputs, and seller-location concurrency.

## Frontend ownership

- `SellerLocationController` owns the editable seller-location mutation state.
- `MapPickerController` owns place search, reverse-geocode selection, current-location resolution, and stale-search protection.
- `SellerMapScreen` owns only transient navigation UI state: current GPS position, rendered route geometry, active maneuver, nearby-map overlay visibility, TTS state, and reroute cooldown.
- Seller profile/store state remains owned by the existing seller providers.

No seller-location business rules are duplicated in widgets.

## Backend contracts used

- Read seller location through `ApiEndpoints.getSellerLocation`.
- Save through `ApiEndpoints.setMySellerLocation` with latitude, longitude, optional `location_name`, optional `location_instructions`, and the last observed `expected_version`.
- Remove through `ApiEndpoints.removeMySellerLocation`, also supplying `expected_version` when known.
- Map points send only the backend-supported viewport/filter fields. The previous unsupported `limit` query parameter is removed.
- Directions use the existing route-to-seller and refresh-route endpoints. Backend route/maneuver data is rendered directly; the client does not synthesize road instructions.

`location_version` is preserved in the frontend location model so concurrent seller-location edits fail safely instead of silently overwriting a newer location.

## UI behavior

- **My Storefront** exposes Customize, Location, and Preview as separate actions. On narrow widths the actions stack rather than overflow.
- **Store Customization** no longer owns store-location editing.
- Banner source selection uses a profile-photo-style dialog rather than another bottom sheet.
- **Storefront Location** provides place search, current location, map selection, resolved address, 140-character location name, 500-character directions note, save, and remove states.
- **Ad Detail / Shop location** renders the actual configured map coordinates and opens the seller-specific map with **View map**.
- **Seller map** presents seller identity, verified badge, map controls, optional nearby seller points, direct Directions, live position updates, route geometry, TTS instructions, off-route refresh, arrival handling, and expandable route steps.
- The Nearby sellers control keeps one label and communicates selection through theme state only: primary/white when selected, surface/textPrimary when unselected. Individual nearby seller pins open that seller's storefront; clusters remain map-navigation targets rather than inventing a seller identity.
- The locked `maplibre_gl` 0.26.2 Android implementation hard-enables its native attribution/info control and exposes positioning but not an enabled flag. The patched AOS map surfaces keep that Android-native info chrome outside the visible map area without changing the package or native project.
- The generic maps explorer remains available for non-seller map use cases.

## Lifecycle, error and accessibility notes

- Navigation position subscriptions and TTS are stopped on dispose and when navigation ends.
- Repeated route starts and seller-location saves are guarded while requests are in flight.
- Search continues to use the existing serial/stale-response protection in `MapPickerController`.
- Controls have tooltips/labels and layouts avoid fixed horizontal action rows on narrow storefront screens.
- Backend failures are surfaced through the existing `ShowSnack` UI rather than inferred from message text.

## Offline behavior

Map tiles, geocoding, seller-map points, route creation, and route refresh require their existing network services. The patch does not fabricate offline routes or persisted map results. An already rendered screen may remain visible while connectivity is lost, but new route/search operations surface their existing request failure.

## Tests

Added coverage verifies:

- seller `location_version` is retained and sent back as `expected_version`;
- location removal sends the known expected version;
- seller map-points requests no longer send the unsupported `limit` parameter;
- seller-specific map routing stays separated from the generic explorer;
- Store Customization no longer owns seller-location editing;
- the seller banner source chooser uses a dialog;
- the Nearby sellers toggle keeps a stable label and applies selected/unselected theme colors;
- nearby seller circle taps route to the existing seller storefront navigation;
- all patched MapLibre surfaces apply the Android-native info-control suppression helper.

## Validation

Flutter/Dart executables were unavailable in the generation environment, so these checks were **not executed** and must be run in the project environment:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/maps test/features/sellers/location
flutter test
flutter build apk --debug
```

Also device-test phone/tablet/foldable layouts with 200% text scale, landscape, keyboard open, RTL, light/dark mode, location permission denied, slow/offline network, repeated Directions taps, route deviation, and seller-location conflict/retry.

## Delivery classification

**Shorebird OTA candidate.** This patch changes Dart code, tests, and docs only. It does not change native permissions, plugins, assets, SDK constraints, storage schema, or dependencies. A normal store release remains appropriate if bundled with unrelated native changes.
