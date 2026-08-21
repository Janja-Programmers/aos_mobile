# Catalog

## Scope and backend authority

Catalog renders the public marketplace taxonomy, supplies category selection
for Ad creation, and provides category filters for Ad discovery. The backend
remains authoritative for activation, ancestry, ordering, sellability, schema
inheritance, pricing, validation, permissions, and rate limits.

The frontend targets the current `aos.api.v1.catalog` contract. It does not send
an `include_inactive` compatibility flag and does not infer that a category is
sellable merely because it currently has no visible children.

## API contract

`GET /api/method/aos.api.v1.catalog.get_categories` is guest-readable and
returns the standard Frappe/AOS envelope. Its `data` value is a deterministic
list of active root nodes. Each node contains:

- `id` and `name` as required strings;
- optional `icon`, `icon_media`, and `icon_media_id`;
- `parent_id`, which is `null` for a root and the root ID for a child;
- non-negative `sort_order`;
- `is_group` as the backend-owned browse/sellability flag;
- `children` as a list.

The backend tree is bounded to two levels. Root groups are browseable but not
sellable. Legacy standalone root leaves remain sellable. Nested nodes are leaf
categories.

`GET /api/method/aos.api.v1.catalog.get_category_schema` remains consumed by
the Ad form. The existing frontend schema model follows the code-derived keys
`pricing_requirement`, `allowed_price_types`, and `allowed_price_units`.

## Architecture and state

- `CategoriesApi` unwraps the Frappe envelope and converts `data` into typed,
  immutable `CategoryNode` objects at the network boundary.
- `CategoriesRepository` is the test seam used by Catalog and marketplace list
  controllers.
- The parser validates required fields, unique IDs, parent relationships,
  two-level depth, and group/leaf structure. A contract violation becomes a
  parse `Failure`; it cannot escape into widget build as a cast or index error.
- `CategoriesController` is the single owner of loading, data, selection, and
  error state. Request generations prevent an older reload from overwriting a
  newer response.
- Reload preserves the selected root only while that exact backend ID still
  exists. Empty results clear selection.
- `AllAdsController` reuses the same typed tree instead of reparsing dynamic
  maps into a second Catalog representation.

No category tree is persisted locally. A new application process reads the
current public taxonomy. There is no fabricated offline Catalog cache.

## UI and failure behavior

- Loading, empty, populated, and error states are explicit.
- The Catalog error state is scrollable and exposes a localized retry action.
- Missing or failed icon media renders a category fallback icon.
- Ad category selection branches on backend `is_group`. An empty group opens an
  empty subcategory state and is never returned as a sellable category.
- Opening Category from the Ad Basic Step always starts at the root-category
  list. Selecting a group pushes its child list, so Back returns child → parent
  → Ad form. The existing selected category remains visible in the form field
  until the user chooses a replacement.
- Group IDs may still be used for Ad browsing because backend Ads filtering
  expands an active group to its active leaf children.

Backend error IDs such as `RATE_LIMIT`, `CATALOG_DATA_ERROR`, and
`INTERNAL_ERROR` are mapped by the shared API failure boundary. UI logic does
not branch on backend message text.

## Security and privacy

Catalog reads are public and expose only the reviewed taxonomy fields. The
frontend does not request inactive records or administrative fields. Category
configuration and icon mutation remain Frappe Desk/System Manager workflows;
the mobile app has no Catalog mutation surface.

## Tests

- `test/features/catalog/domain/category_node_test.dart` covers the exact tree
  fields, optional media, group-owned sellability, and malformed nodes.
- `test/features/catalog/data/categories_api_test.dart` covers the Frappe
  envelope, exact endpoint/query contract, valid empty trees, malformed tree
  failure, and backend error propagation.
- `test/features/catalog/application/categories_controller_test.dart` covers
  success, retry, error, selection preservation, selection clearing, and stale
  response protection.
- `test/features/catalog/regression/category_picker_navigation_source_test.dart`
  prevents the Ad form from passing a selected parent as the picker entry route
  and preserves the group-to-child push behavior.

## Validation

Run from a complete project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/catalog
flutter test test/features/ads
flutter test
flutter build apk --debug
```

The delivery archive contains `lib/`, `test/`, `docs/`, and
`analysis_options.yaml`, but not the project `pubspec.yaml`/lockfile. Flutter
and Dart were also unavailable in the delivery environment. The commands above
therefore remain to be run from the complete application root; structural
source, import, archive, and contract checks were performed before packaging.

## Release classification

**Shorebird OTA candidate.** This fix changes Dart source, tests, and docs only.
It adds no native code, plugin, permission, asset, dependency, or storage
migration.
