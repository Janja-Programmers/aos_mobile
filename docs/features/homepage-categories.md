# Homepage categories

## Purpose

Homepage category-driven content must use the backend catalog as its taxonomy
source. Category names are presentation data; canonical category IDs are the
only identity sent to ad listing/navigation flows.

## State ownership

- `CategoriesApi` / `categoriesControllerProvider` owns the backend category
  tree and its loading/error lifecycle.
- `HomePageController` owns homepage composition and ad requests.
- Widgets render the composed state only; they do not choose or resolve
  categories.
- Display-name-to-ID matching and the former Home section compatibility provider
  are retired and deleted. No second Home section state/network API is kept.

## Backend contracts

Catalog source:

- `GET /api/method/aos.api.v1.catalog.get_categories`
- The frontend consumes active public parent categories already validated and
  ordered by the backend catalog contract.

Homepage category ad rails use the existing ads listing contract:

- one `category` query value per request;
- the value is `CategoryNode.id`;
- group-to-leaf resolution remains backend-owned;
- no comma-separated category names or frontend category expansion is used.

## Homepage composition

Fixed merchandising/content sections remain fixed because they are not
catalog taxonomy:

- Flash Sales
- New Products
- Deals
- Live & Shorts
- ranking/seller guidance
- promotional banners
- Discover More

Category-specific rails are dynamic:

1. read parent `CategoryNode`s from `categoriesControllerProvider`;
2. deduplicate by canonical ID;
3. select up to four parents with a deterministic seeded Fisher-Yates shuffle;
4. keep the selection stable across ordinary rebuilds;
5. use `category.name` as the rail label;
6. use `category.id` for `listAds` and See All navigation.

The top category discovery preview intentionally keeps backend order. Only the
deeper category ad rails are shuffled, matching the useful behavior of the AOS
web homepage without making primary navigation unpredictable.

## Selection lifecycle

The seed combines:

- current market/country identity;
- one Home controller session seed;
- an explicit selection epoch.

Consequences:

- widget rebuilds, theme changes and unrelated provider notifications do not
  randomly reorder categories;
- a market/country change produces a market-specific selection;
- pull-to-refresh advances the selection epoch once and may rotate the four
  category rails;
- fewer than four categories renders only the available backend categories;
- no fallback category names are fabricated.

## Loading, errors and races

The Home controller does not make category loading a second network owner.
When catalog state arrives after initial Home content, only dynamic category
rails are composed/loaded; fixed merchandising and Discover content are
preserved.

In-flight ad requests are keyed by effective request parameters so overlapping
provider recomputation cannot issue the same request twice while it is still
running. Full Home refresh/location changes increment a request generation so
stale pagination or reload results cannot take ownership of newer state.

If catalog loading fails, Home does not substitute hardcoded taxonomy. Existing
non-category content remains usable. Empty category rails are omitted by the
existing section rendering behavior.

## Navigation and identity

Dynamic category sections use keys of the form:

`category:<canonical-category-id>`

The key is local presentation/state identity only. Backend identity remains the
separate `categoryId` field.

The brand mini-category panel is also populated from the selected backend
categories. If no categories are available, the promo slider expands to the
full section width instead of showing an empty category panel.

## Cleanup contract

The completed migration deletes rather than deprecates internal compatibility
artifacts when they have no remaining consumers. The following files must stay
absent:

- `lib/features/home/shared/providers/home_section_ads_provider.dart`
- `lib/features/home/shared/providers/home_page_providers.dart`
- `lib/features/home/domain/market_place.dart`
- `lib/features/home/shared/utils/category_lookup.dart`

Localization keys that existed only for the former hardcoded category rails are
also removed from source ARBs. Generated localization Dart files are refreshed
with `flutter gen-l10n`; they are not edited manually.

## Security and trust boundary

The frontend does not infer permissions, category activity, ancestry,
eligibility or group expansion. Those remain backend responsibilities.
Frontend category data is treated as display/navigation metadata supplied by
the authoritative catalog endpoint.

## Tests

- `test/features/home/domain/home_category_selection_test.dart`
  - deterministic selection;
  - uniqueness and four-item cap;
  - fewer-than-four behavior;
  - no input mutation;
  - canonical ID/display title separation.
- `test/features/home/presentation/controller/home_page_controller_test.dart`
  - Home requests category ads with canonical IDs only.
- `test/features/home/regression/homepage_categories_source_contract_test.dart`
  - fixed taxonomy cannot return to Home configuration/UI;
  - Home controller remains the network owner;
  - retired compatibility files stay deleted;
  - obsolete fixed-taxonomy localization keys stay deleted;
  - top category preview stays backend ordered.

## Device regression checklist

- Cold start: top category preview and category rails come from current backend
  categories.
- Tap each dynamic rail See All: results correspond to that canonical category.
- Theme/rebuild: rails do not reshuffle/flicker.
- Pull-to-refresh: selection may rotate once; no duplicate rails/requests.
- Slow/error/offline catalog: fixed Home content remains usable; no hardcoded
  fallback taxonomy appears.
- Backend rename/deactivation: reflected after catalog state refresh without app
  code changes.
- Small screen, landscape, RTL and 200% text: no RenderFlex/horizontal overflow.
- Missing category icon: dynamic rails/category links remain reachable by text.

## Validation

Run from the complete application root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/home
flutter build apk --debug
```

## Delivery impact

**Shorebird OTA candidate.** The implementation changes Dart source, source
localizations, tests and documentation only. It does not add packages, native
code, permissions, assets, SDK changes or storage migrations.
