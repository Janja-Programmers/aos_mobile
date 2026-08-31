# Activity Center

## Status and scope

Activity Center is private authenticated history backed by the backend Activity
contract. The backend owns activity groups/types, active/hidden/cleared status,
visibility, ordering, offset pagination, ownership and clear/hide semantics.

The Flutter frontend consumes the existing backend capability; it does not implement
Activity hiding as local-only state.

## Backend contracts represented by the frontend

The feature uses:

- `list_activity` — GET, `start`, `limit`, optional `group`/`type`;
- `hide_activity` — POST, canonical `activity_id`;
- `clear_activity` — POST, optional canonical `group`/`type`.

The backend returns only the authenticated user's Active rows. Hide is owner-scoped
and idempotent. Clear applies only to that user's history and may be filtered by
group/type.

The frontend page size is 20 while the backend permits up to 50.

## Architecture and state ownership

`ActivityCenterController` owns:

- the selected group;
- currently loaded rows;
- backend `start`, `total` and `hasMore` values;
- initial/load-more/error state;
- hide mutation tracking;
- clear serialization;
- stale-response generation guards.

`ActivityRepository` is the controller dependency seam. `ActivityApi` implements it
using the production API client; tests use fakes instead of production services.

No second Activity store/provider is introduced.

## Pagination and mutation consistency

Activity uses offset pagination, not Notification cursor pagination.

A successful hide removes a row from the already-consumed prefix. The controller
therefore decrements the consumed `start` and `total` before the next load-more so a
row is not skipped because backend offsets shifted.

While hides are in flight:

- load-more is blocked;
- older page responses are invalidated;
- duplicate hide calls for the same ID are suppressed;
- a filter/load race triggers authoritative refresh rather than applying an old
  offset to a new dataset.

A failed hide reconciles from REST and surfaces the error.

Clear waits for already-started hides to settle and prevents new destructive work.
A pending group clear supersedes individual hide failure/refresh handling, avoiding
an intermediate row flash before the broader clear completes.

The auto-dispose controller invalidates outstanding request generations during
disposal so late network completions cannot update disposed state.

## UI behavior

The Activity Center keeps the existing group filters and exposes the backend hide
capability in two accessible interactions:

- swipe from the trailing edge to Hide;
- long press -> Hide from activity.

The app-bar Clear action confirms before invoking backend `clear_activity` for the
selected group.

The list supports initial loading, empty, initial error/retry, pull-to-refresh,
load-more progress and incremental error/retry.

Tiles use wrapping metadata and two-line title/subtitle limits to reduce overflow
risk with large text and narrow layouts.

## Navigation and stale historical targets

Activity is historical, so a target can stop being valid after the activity row was
created.

For `route_type=ad`, the frontend validates the canonical route ID and preflights
the existing public ad API before routing to Ad Detail. If the ad no longer satisfies
the public `get_ad` contract, the user remains in Activity Center and receives an
informational message instead of being routed into an unavailable detail state.

Other canonical route types continue through their existing feature navigation:
Short, Live, Profile and user search.

## Security and trust boundaries

- Activity IDs and route IDs are backend-owned.
- Hide/clear remain authenticated server operations.
- The frontend does not infer ownership or change Activity status locally without
  issuing the corresponding backend mutation.
- Route identifiers are constrained before navigation.
- Backend errors remain authoritative; failed optimistic hides reconcile from REST.

## Automated tests

Relevant coverage is under `test/features/activity/`:

- first-page and offset load-more behavior;
- hide offset adjustment so the next row is not skipped;
- hide-failure authoritative reconciliation;
- load-more suppression during hide;
- hide-versus-clear serialization without intermediate refresh;
- stale response protection after group switching;
- source-contract guards for backend hide, UI exposure, destructive pagination
  guards, historical ad preflight and group-aware clear.

## Validation

Run from the Flutter project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/activity
flutter test test/features/notifications
flutter test
flutter build apk --debug
```

These commands were not executed in the handoff environment because Flutter/Dart
executables were unavailable.

## Known boundaries

Activity hide is not Notification hide. Notifications must continue to use their
own delete/clear contract. Activity remains offset-paginated and must not be migrated
to Notification cursor behavior unless the backend Activity API changes.
