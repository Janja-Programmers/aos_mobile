# Ad Creation

## Backend boundary

`backend.zip` is authoritative for create, draft, update, submit, validation,
market selection, canonical identifiers, and moderation transitions.

The create and draft payload builder serializes only backend-supported ad
fields. Account country remains frontend draft context but is not sent as an ad
input because the backend derives market country from authenticated preferences
and the selected canonical location. `scheduleOfferDates` is UI state only; it
controls whether `offer_start_date` and `offer_end_date` are included and is
never serialized as `schedule_offer_dates`.

## Location search

The location picker uses server-side search and offset pagination:

```text
q
limit = 20
offset
pagination.has_more
pagination.next_offset
```

`LocationSearchController` owns the query, initial loading, lazy loading,
errors, pagination, duplicate suppression, debounce, and stale-response
protection. The picker requests the next page near the end of the scroll view.
“All Locations” appears only for an empty query.

## Category navigation

Opening Category from the Basic Step starts at the public root-category list,
including when the draft already has a selected leaf. Selecting a backend
`is_group` category pushes its child list. Back navigation therefore follows
child list → parent list → Ad form instead of leaving the picker directly from
the child list. The current draft category is changed only after a leaf is
selected and returned to the form.

## Failure behavior

- Initial location failures show a scroll-safe retry state.
- Page failures preserve already loaded locations and expose a footer retry.
- Rapid query changes invalidate older requests.
- Duplicate page requests are ignored while a page is loading.
- `INVALID_AD_INPUT` is mapped through the existing API failure boundary; the
  frontend does not infer missing backend fields from human-readable messages.

## Tests

Focused coverage:

- `test/features/ads/ads_form/utils/ad_form_payload_test.dart`
- `test/features/ads/data/ads_api_locations_test.dart`
- `test/features/ads/data/ads_api_mutation_contract_test.dart`
- `test/features/ads/ads_form/application/location_search_controller_test.dart`
- `test/features/catalog/regression/category_picker_navigation_source_test.dart`

These tests protect the backend field allowlist, pagination parameters,
response parsing, lazy loading, deduplication, stale-response handling, and the
parent/child category-picker navigation stack.
