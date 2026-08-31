# Notifications

## Status and scope

The Flutter Notification Center is a client of the backend-owned AOS Notification
contract. Persistent rows, canonical IDs, categories, unread counts, deletion,
category/all clear semantics, cursor pagination, realtime actions and rate limits
remain backend-owned.

Frontend state must not invent persistent notifications, backend categories,
unsupported hide/archive semantics, or selected-ID batch deletion.

## Architecture and state ownership

`NotificationController` is the single owner of:

- the selected backend category;
- the currently loaded page rows;
- global authoritative `unreadCount`;
- `nextCursor` and load-more state;
- initial-load/refresh/error state;
- point-mutation and batch-clear serialization;
- stale-response invalidation.

`notificationUnreadCountProvider` is a projection of controller state rather than a
second counter.

The visible tabs map directly to backend categories:

| UI tab | Backend category |
| --- | --- |
| All | `all` |
| Messages | `communication` |
| Activity | `activity` |
| Marketplace | `marketplace` |
| Account | `account` |

`Messages` intentionally contains both `message` and `missed_call`, matching the
backend communication category.

## REST integration

The frontend consumes the existing notification endpoints through `ApiEndpoints`:

- `list_notifications`: GET with `category`, `limit`, optional `before`;
- `mark_notification_read`: POST with `notification_id`;
- `mark_all_notifications_read`: POST with no category;
- `delete_notification`: POST with one `notification_id`;
- `clear_notifications`: POST with `category`.

List pagination is backend keyset pagination. The controller:

- requests 20 rows per page;
- passes backend `next_cursor` back as `before`;
- prevents concurrent load-more requests;
- deduplicates canonical IDs;
- ignores stale category/page responses;
- restarts from the first page on refresh;
- invalidates a cursor when the cursor row is deleted and then refreshes.

`unread_count` is global and authoritative. It is never inferred from the currently
loaded category/page.

## Mutations

### Single delete

Swipe-to-delete is preserved. Long press exposes Delete. There is no Notification
Hide action because the backend has no hide/archive endpoint.

Single delete is optimistic, but a backend failure triggers an authoritative first
page reconciliation. There is no local Undo for a successful backend deletion.

### Mark read / mark all read

Read mutations update the visible UI optimistically, then accept the backend
`unread_count`. A failed point mutation reconciles from REST.

### Clear

The three-dot menu exposes Mark all as read and Clear. `clear_notifications` applies
to the currently selected backend category; All sends `category=all`.

Clear is serialized behind point mutations. Once a broader Clear has started,
existing point-mutation failures do not issue an intermediate REST refresh that
could briefly repopulate rows before the clear completes.

The backend has no selected-ID batch-delete contract, so multi-select delete is not
implemented.

## Realtime and lifecycle

Persistent Notification Center synchronization consumes only
`aos_notification_center` version 1. The supported actions are:

- `created` — serialized notification + `unread_count`;
- `read` — `notification_id` + `unread_count`;
- `read_all` — `unread_count`;
- `deleted` — `notification_id` + `unread_count`;
- `cleared` — category/deleted count + `unread_count`.

The listener does not synthesize persistent notification rows from older domain
Socket.IO events. Raw Socket.IO event names are retained on `RealtimeEvent` so the
canonical Notification Center event can coexist with the existing Chat/Calls/Live
event enum without expanding that enum and risking exhaustive-switch regressions.

Invalid realtime counts/categories reconcile from REST. Socket reconnect and app
resume reconcile the selected category. Deleted-ID tombstones reduce out-of-order
create/delete races; REST remains authoritative.

Incoming calls remain transient and are owned by the Calls pipeline rather than the
persistent Notification Center.

## Models

Persistent rows require a backend-owned canonical notification ID. Push messages
without `notification_id` remain transient and are not treated as persistent inbox
rows.

The type/category model includes the canonical backend types, including:

- `short_mention`;
- `review_received`;
- `review_approved`;
- `review_rejected`.

Actor display names prefer backend `actor_display_name`, while actor identity stays
separate as the canonical public account ID.

## Navigation

Destination parsing accepts validated canonical IDs and an allowlist of internal
routes only. External URLs, protocol-relative URLs, traversal and malformed IDs are
rejected.

Current lifecycle handling:

- `ad_approved` -> Ad Detail candidate;
- review notifications -> referenced Ad Detail candidate;
- `ad_rejected` -> My Ads/My Listings;
- `ad_expired` -> My Ads/My Listings;
- Short activity/mention/reply -> Short Detail;
- verification approved -> Account;
- verification rejected -> Verification;
- missing/stale targets -> safe feature fallback.

Before opening public Ad Detail, `GoRouterProtectedNavigationExecutor` calls the
existing public ad API. If the ad is no longer publicly fetchable, navigation falls
back to Notification Center instead of opening an impossible detail state.

## UI, accessibility and responsive behavior

The screen supports:

- initial loading;
- empty state;
- initial error/retry;
- pull-to-refresh;
- incremental loading and retry;
- server-backed category tabs;
- swipe delete and long-press delete;
- scroll-safe notification action sheets;
- semantic selected/read state;
- missing avatar fallback;
- responsive time/body layout.

Physical testing must still cover 200% text scale, RTL, screen readers, small
screens, landscape, light/dark mode, slow network and lifecycle transitions.

## Automated tests

Relevant coverage is under `test/features/notifications/`:

- canonical type/category mapping and payload parsing;
- canonical-vs-transient push IDs;
- safe destination parsing and lifecycle-specific ad routes;
- first page and cursor pagination;
- duplicate load-more suppression;
- stale-category response protection;
- category batch clear;
- failed-delete REST reconciliation;
- point-mutation versus Clear serialization;
- category-aware realtime insertion;
- canonical realtime create/delete;
- rejection of old domain realtime events;
- invalid realtime count reconciliation;
- reconnect reconciliation;
- source-contract guards for categories, delete/clear, canonical realtime and ad
  preflight behavior.

## Validation

Run from the Flutter project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/notifications
flutter test
flutter build apk --debug
```

These commands were not executed in the handoff environment because Flutter/Dart
executables were unavailable.

## Backend boundaries

Do not add Notification hide/archive, selected-ID bulk delete, fabricated IDs,
frontend-derived global unread counts, or frontend-owned category rules unless the
backend contract changes first.

## Targeted navigation and missed-call callback hardening

### My Listings navigation

`ad_rejected` and `ad_expired` remain backend-defined marketplace notification
outcomes and continue to resolve to My Ads/My Listings. Because Notification Center
is a standalone top-level route while My Ads is owned by the main shell, the
notification navigation executor uses `goNamed(AppRoutes.nMyAds)` rather than
pushing a second shell destination onto the current page stack.

Safe Notification Center fallbacks use the same non-stacking `goNamed` behavior.
Public Ad Detail navigation remains a push after the existing availability
preflight succeeds.

### Missed-call Call Back handoff

Notification Center does not own an outgoing-call lifecycle. The Call Back action
uses `NotificationMissedCallActionCoordinator` only as a boundary around the
existing Calls implementation:

1. await the existing `CallKitRecoveryService.recover()`;
2. clear the native/pending CallKit representation for the original terminal
   missed-call ID through the existing `CallKitService`;
3. reject the callback if the existing `CallManager` state is busy, has an active
   backend call, has incoming-call UI, or has an active room;
4. single-flight repeated notification action taps;
5. delegate to the existing `MissedCallCallbackService`, which continues through
   the existing `CallStarterService`/`CallManager` lifecycle.

Notification code does not call backend `initiate_call`, does not invoke
`CallManager.startOutgoingCall`, does not register a new outgoing CallKit call, and
does not navigate to a call session directly. Those responsibilities remain owned
by Calls.

The coordinator exposes typed outcomes for started, duplicate-start, active-call,
recovery failure and delegated-start failure. User-visible failure text reuses
existing localized Calls strings.

### Regression coverage for these paths

Additional Notification tests verify:

- My Ads and Notification Center fallback navigation are non-stacking;
- public Ad Detail still uses availability preflight;
- CallKit recovery runs before callback delegation;
- the original missed native call ID reaches recovery/cleanup;
- active Calls state prevents a second outgoing call;
- repeated callback taps are single-flight;
- recovery failure never enters outgoing-call start;
- Notification source never directly initiates/registers an outgoing call.
