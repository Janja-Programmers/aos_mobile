# Ads mobile hardening

## Scope and ownership

This patch hardens the Flutter Ads frontend while keeping the backend as the
single source of truth for Ads business behavior. The frontend does not invent
listing eligibility, status transitions, category pricing, permissions,
moderation rules, canonical IDs, validation, or defaults.

Covered areas:

- Edit Image background-selection race/performance and temp-file ownership.
- Create/Edit/Draft preload and Riverpod lifecycle safety.
- Backend-driven Create/Edit pricing and payload construction.
- Status-aware seller update contracts and actionable errors.
- Canonical Ad Draft API contracts.
- All Ads sort/filter reuse.
- Search-by-image strict request contract.
- Voice-search timeout dismissal.
- My Listings renew contract.

## Backend-driven seller edit contract

`get_my_ad` remains the authoritative seller-edit read. The frontend consumes
`data.item`, including the current listing `status`, category metadata, raw
stored values, canonical media IDs, details and pricing metadata.

Update behavior follows the backend status boundary:

- `Active`: only title, description and pricing fields are eligible for
  `update_ad`. The reduced editor sends change-only fields and never sends
  category, location, details or media changes for an Active listing.
- `Reviewing` and `Declined`: the frontend sends the complete backend-approved
  create/update payload; the backend remains responsible for moving the listing
  through moderation.
- `Sold`, `Expired`, `Deleted` and `Suspended`: the frontend prevents a known
  invalid edit request and explains the required action where applicable. The
  backend still validates the state on every request, which protects against
  stale frontend state.

The shared `AdUpdateContract` is a frontend request allow-list only. It exists to
avoid sending fields the backend contract does not accept; it does not replace
backend authorization or state validation.

## Pricing

Category pricing is read from the backend category schema / seller edit
metadata:

- `pricing_requirement`
- `allowed_price_types`
- `allowed_price_units`
- `is_service`

The frontend no longer fabricates pricing fields for categories whose pricing is
Hidden. Amount-based pricing follows the backend: Fixed and Negotiable require a
positive amount; services also require a price unit; Contact-for-price and Free
do not send a numeric amount; offers are Fixed-only, positive and below the
regular price; offer dates use canonical `offer_start_date` and
`offer_end_date`.

### Fixed-price UX default

When a create/edit/draft form has **no stored price type**, `Fixed` is displayed
as the preselected option only if the backend category permits Fixed pricing.
An existing backend value such as `Negotiable` is preserved and never replaced
by this UI default. Hidden pricing receives no default. A category that does not
permit Fixed is not overridden.

The Frappe persisted zero-value offer sentinel is normalized at the frontend
read boundary: `offer_price <= 0` is treated as no offer. An explicit zero offer
is never sent back as a valid offer.

## Ad Draft API contract

The canonical draft read endpoint is:

```text
/api/method/aos.api.v1.ads.get_my_ad_draft
```

The previous frontend `get_ad_draft` path did not exist in the backend v1
wrapper and caused HTTP 417. Draft read now uses the canonical endpoint and
unwraps:

```text
data.item
```

Draft list requests now send only the backend-supported pagination fields:

```text
limit
offset
```

They no longer reuse public-ad filters or market-context injection. Draft
submit/status mutations use explicit POST request bodies. Draft upsert keeps the
backend-owned `draft_id` + `payload` contract.

## Payload serialization

`AdFormPayloadBuilder` serializes only backend contract fields. It uses backend-supported category attribute keys for `details` (which the
backend resolves to canonical attribute IDs), canonical media IDs for
images/video, and canonical offer-date keys. The frontend does not send display labels, public
media URLs, seller IDs, country/currency defaults, moderation status or other
backend-owned fields as create/update authority.

Active reduced edits are intentionally partial. Reviewing/Declined resubmits
are full payloads because the backend requires the create-field contract for
those states.

## User-facing backend errors

The API layer preserves backend machine-readable error IDs. Ads UI maps known
stable IDs to concise actionable text while retaining the server message as the
fallback. Examples include:

- `INVALID_AD_STATE`: explain that the current listing state does not allow the
  action and, when known, direct Expired -> Renew or Sold -> Mark available.
- `AD_PRICE_REQUIRED`: ask for a valid price for the selected type.
- `INVALID_CATEGORY_SCHEMA`: explain that category values/pricing must be
  reviewed.
- `AD_SELLER_INACTIVE` / `SELLER_REQUIRED`: explain seller eligibility.
- `AD_MEDIA_REQUIRED`, `AD_PRIMARY_IMAGE_REQUIRED`, duplicate media/attribute
  errors: explain the concrete form correction.
- market/location/category errors: explain the backend-owned restriction.

The frontend does not infer success/failure from free-form message text and does
not bypass a backend rejection.

## Image editor

Background colour/gradient taps update local preview state immediately instead
of queueing PNG work. The transparent foreground is composited in the widget
tree; the selected background is flattened once on Done. This keeps selector
and preview synchronized even under rapid taps.

Background-removal output remains temporary until the completed edit uploads
successfully. Cancel/failure leaves the original draft image intact, and temp
file ownership prevents the editor from deleting a file while its caller is
still uploading it.

## Preload and lifecycle

`adDraftControllerProvider` remains the single owner of the current ad draft.
Edit Ad and Edit Draft wait for authoritative preload and the category schema
before stateful steps are created. Generation tokens reject stale network
responses. Widget-triggered provider initialization is deferred until after the
first frame to comply with Riverpod lifecycle constraints.

Basic and Description steps use the active `AdFormMode`; they do not read the
Create-mode controller during Edit.

## All Ads, image search, voice search, renew

All Ads reuses the existing sort/filter sheets and controller. Search by image
uses the shared media layer and sends the multipart image plus the supported
limit only; the removed `is_private` field was not accepted by the strict
backend image-search contract.

`speech_to_text` `error_speech_timeout` is a silent terminal outcome: the voice
sheet dismisses instead of presenting an error. Other speech errors remain
visible.

My Listings renew continues to call the backend status action `renew`; no
separate renew endpoint or frontend expiry rule was added.

## Tests

Regression coverage includes:

- `test/features/ads/data/ads_api_contract_source_test.dart`
- `test/features/ads/domain/ad_draft_preload_test.dart`
- `test/features/ads/ads_form/ad_preload_source_contract_test.dart`
- `test/features/ads/ads_form/ad_update_contract_test.dart`
- `test/features/ads/ads_form/ad_failure_message_test.dart`
- `test/features/ads/ads_form/pricing_default_contract_test.dart`
- `test/features/ads/ads_form/edit_image_background_source_contract_test.dart`
- `test/features/ads/ads_all/all_ads_sort_filter_source_contract_test.dart`
- `test/features/search/voice/voice_timeout_policy_test.dart`
- `test/features/search/image_search_contract_test.dart`

These protect canonical endpoints/envelopes, backend status allow-lists, draft
pagination contract, pricing default behavior, zero-offer normalization,
preload/stale-response guards, Riverpod-safe startup, image-search multipart
fields, sort/filter reuse and silent speech timeout behavior.

## Accessibility and localization

New error/retry states remain safe-area constrained and scrollable. Existing
shared controls are reused. The Ads feature still contains pre-existing
hard-coded English strings; this patch does not introduce a competing
localization mechanism. A feature-wide localization pass remains separate work.

## Validation commands

Run from the repository root after applying the patch:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter build apk --debug
```

## Delivery classification

**Shorebird OTA candidate.** The patch changes Dart source, tests and docs only.
It adds no plugin, native permission/code, dependency/SDK upgrade, asset change
or storage migration.
