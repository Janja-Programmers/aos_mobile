# AOS Live

## Status

The Flutter Live implementation is **implemented and ready for analyzer/device validation**. The backend remains immutable and authoritative for lifecycle, permissions, canonical IDs, validation, rate limits, viewer tracking, comments/replies, deletion, aggregates, and co-host transitions.

This update completes the Live detail hardening pass without adding dependencies or native configuration.

## What this frontend now represents

- Feed → Live uses the same Shorts-style two-column discovery/listing model. A card tap opens the Live detail/room; Feed browsing no longer silently joins a LiveKit room.
- The viewer-count control opens the current LiveKit-backed audience list while the numeric count remains backend-authoritative.
- Signed-in viewer/co-host entries expose backend-issued public account IDs and may open an in-room brief profile sheet, then the existing full public profile route. Guest entries remain non-profileable.
- Live comments render backend identity data including avatar and verified state.
- Persisted replies are recovered inline through `include_replies=1`; the composer can reply to a selected message and sends backend-supported idempotency keys.
- Comment history uses backend cursor pagination and keeps one controller/state owner.
- Author/host delete actions call the canonical delete endpoint. The controller handles backend-recursive descendant IDs and tombstones them so late realtime/history events cannot resurrect deleted branches.
- After the owner ends a Live, the canonical `end_live` `data.live` snapshot is preserved through `LiveApi → LiveRepository → LiveManager` and shown in an owner-only post-Live analytics dialog.

Post-Live analytics mapping is exact:

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
| `LiveScreen` | Presentation and intent dispatch only |
| `ShortsFeedTab` | Live discovery listing/navigation only |

No competing Live state store, API client, persistence layer, or realtime listener is introduced.

## Security and privacy

- Viewer list/profile actions use only LiveKit metadata issued by the backend (`account_id`, display name, avatar, role, guest flag) and opaque LiveKit identity where required by co-host APIs.
- Tokens, WebSocket credentials, internal user IDs, and private viewer session IDs are not rendered or shared.
- Guests cannot be treated as public profiles because no canonical public account ID is available.
- UI delete affordances are only a convenience; backend author/host permission checks remain authoritative.
- Aggregate viewer count is never derived from the local participant list.

## UI/lifecycle requirements

Changed Live surfaces must remain usable on small screens, landscape, keyboard-open layouts, RTL, dark/light themes, and text scaling through 200%. Viewer/profile sheets and post-Live analytics are safe-area/scroll aware. Comment input remains keyboard-aware, and comment history has explicit loading/end behavior.

## Validation

Run from the project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze .
flutter test test/features/live
flutter test
flutter build apk --debug
```

The supplied archive was not analyzer-executed in the packaging environment because Flutter/Dart are unavailable there.

## Delivery classification

**Shorebird OTA candidate.** This pass changes Dart source, tests, and documentation only. It does not change `pubspec.yaml`, locked dependencies, Android/iOS source, permissions, assets, or native plugin configuration.
