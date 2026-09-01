# AOS Live

## Status

The Flutter Live implementation is **implemented and ready for analyzer/device
validation**. The backend remains immutable and authoritative for lifecycle,
permissions, canonical IDs, validation, rate limits, viewer tracking,
comments/replies, deletion, aggregates, co-host transitions, and Live list
pagination.

This update changes Live discovery/list presentation and navigation only; it does
not add dependencies or native configuration.

## Feed → Live discovery

The Feed `Live` tab now follows the supplied Live listing reference while reusing
the existing Feed/list architecture:

- a localized `LIVE now` section header and subtitle;
- pull-to-refresh plus an explicit refresh control;
- a two-column Live grid;
- cover/thumbnail with a neutral missing-media fallback;
- red `LIVE` badge;
- backend-authoritative `viewer_count` with an eye indicator;
- Live title and host display name;
- explicit loading, empty, error/retry, pagination loading, and pagination retry
  states.

The authoritative list path remains `LiveApi.listLives` → backend
`list_live_streams`. Cursor pagination and canonical Live IDs are preserved.

A discovery card tap uses the existing `LiveNavigation.toLiveRoom` route with
`live_id=<canonical id>`. Browsing the list itself never calls `join_live`,
LiveKit, `track_join`, or viewer presence. Presence begins only after the user
opens Live detail and the existing Live session owner performs the backend join.

## What this frontend represents

- Feed → Live uses the same two-column discovery model as Shorts, with Live-
  specific card content rather than Short interaction overlays.
- The viewer-count control inside Live detail opens the current LiveKit-backed
  audience list while the numeric count remains backend-authoritative.
- Signed-in viewer/co-host entries expose backend-issued public account IDs and
  may open an in-room brief profile sheet, then the existing full public profile
  route. Guest entries remain non-profileable.
- Live comments render backend identity data including avatar and verified
  state.
- Persisted replies are recovered inline through `include_replies=1`; the
  composer can reply to a selected message and sends backend-supported
  idempotency keys.
- Comment history uses backend cursor pagination and keeps one controller/state
  owner.
- Author/host delete actions call the canonical delete endpoint. The controller
  handles backend-recursive descendant IDs and tombstones them so late
  realtime/history events cannot resurrect deleted branches.
- After the owner ends a Live, the canonical `end_live` `data.live` snapshot is
  preserved through `LiveApi → LiveRepository → LiveManager` and shown in an
  owner-only post-Live analytics dialog.

Post-Live analytics mapping remains exact:

| UI metric | Backend field |
| --- | --- |
| Peak | `peak_viewers` |
| Viewers | `unique_viewers` |
| Reactions | `reaction_count` |

## State ownership

| Owner | Responsibility |
| --- | --- |
| `LiveManager` | Active Live/session/media lifecycle, stale transition protection, authoritative Live snapshot, reactions, end result |
| `LiveMediaService` / `LiveKitService` | LiveKit room/media ownership and current audience participant snapshots |
| `LiveCommentsController` | History, cursor pagination, reply submission, duplicate-submit prevention, realtime merge, optimistic/recursive delete handling |
| `LiveRealtimeCoordinator` | Sole socket event coordinator and reconnect recovery |
| `LiveCohostController` | Canonical co-host workflow intent/state |
| `LiveProfileProvider` | Read-only brief public profile data using the existing Accounts API |
| `LiveScreen` | Presentation and Live detail/session intent dispatch only |
| `ShortsFeedTab` | Feed Live discovery list, cursor pagination, refresh, stale-response protection, and navigation intent only |

No competing Live state store, API client, persistence layer, or realtime listener
is introduced.

## Security and privacy

- Viewer list/profile actions use only LiveKit metadata issued by the backend and
  opaque LiveKit identity where required by co-host APIs.
- Feed Live cards consume only display-safe list fields already mapped into
  `LiveStream`.
- Tokens, WebSocket credentials, internal user IDs, and private viewer session
  IDs are not rendered or shared.
- Guests cannot be treated as public profiles because no canonical public
  account ID is available.
- Aggregate viewer count is never derived from the local participant list.
- Backend block/access rules decide which Live rows are listable and watchable.

## UI, localization, and accessibility

The Feed Live list uses the existing feature-localization approach for English,
French, Arabic, Swahili, and Chinese. Live cards and refresh actions have semantic
labels; directional positioning is used for RTL-safe overlays. The grid is
covered by narrow-screen, RTL, dark-mode, and 200%-text-scale widget tests.
Missing cover media renders a stable broadcast placeholder rather than a broken
network surface.

Existing Live detail surfaces must continue to remain usable on small screens,
landscape, keyboard-open layouts, RTL, dark/light themes, and text scaling
through 200%.

## Tests

Feed/Live discovery coverage added by this pass:

- `test/features/shorts/feeds/feed_live_navigation_source_contract_test.dart`
- `test/features/shorts/feeds/feed_cards_responsive_test.dart`
- `test/features/shorts/feeds/feed_card_formatters_test.dart`

Existing `test/features/live` coverage remains authoritative for Live detail,
media, comments, realtime, co-host, and lifecycle behavior.

## Validation

Run from the project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze .
flutter test test/features/shorts/feeds
flutter test test/features/live
flutter test
flutter build apk --debug
```

The supplied archive was not analyzer-executed in the packaging environment
because Flutter/Dart are unavailable there.

## Delivery classification

**Shorebird OTA candidate.** This pass changes Dart source, tests, and
documentation only. It does not change `pubspec.yaml`, locked dependencies,
Android/iOS source, permissions, assets, or native plugin configuration.
