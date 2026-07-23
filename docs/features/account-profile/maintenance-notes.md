# Maintenance Notes

## Safe extension checklist

1. Confirm backend wrapper, implementation, validator, serializer, permissions, and tests.
2. Add or update a sanitized response fixture matching the exact envelope.
3. Update a request/response model rather than parsing new fields ad hoc in widgets.
4. Preserve owner/public/deleted/blocked visibility rules.
5. Use existing navigation helpers and provider invalidation paths.
6. Add success, failure, malformed, and privacy regression tests.
7. Re-run Authentication/Session and complete Flutter suites.

## Known limitations

- Backend connection-list endpoints are current-user-only, so public connection totals are not navigable.
- Profile follow mutation reloads the profile rather than applying an optimistic counter update.
- Media tests do not exercise native permissions, camera/gallery, filesystem, or real upload.
- Seller, Shorts, Activity, Chat, Live, and Verification are integration-only here.
- `ProfileScreen` currently requires authentication; no guest-public-profile mode is implemented even though backend serializer visibility must still remain safe.
- Restore is exposed in Account settings even though its backend endpoint is guest-oriented; product routing/presentation can be revisited in a dedicated account-lifecycle review.

## Risks to watch

- Adding a database field to public Profile UI without serializer/privacy review.
- Reintroducing target-user parameters to current-user-only social lists.
- Treating action-label text as the relationship state.
- Swallowing profile failures into interactive fallback data.
- Creating a separate current-user cache that survives logout.
- Replacing shared `humanizeCount` with local formatting.

## Recommended next phase

Ads and Listings are the recommended next feature after Account/Profile because Account routes directly into My Listings and profile counts/content depend on marketplace ownership and visibility contracts. Seller and Verification should follow as a separate phase because their submission and storefront rules are intentionally outside this delivery.
