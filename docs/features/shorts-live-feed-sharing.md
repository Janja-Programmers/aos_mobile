# Shorts feed and media sharing

## Scope

This iteration hardens the Feed landing page category requests and the system
share flows for Shorts and active Live sessions. Backend behavior remains the
source of truth.

## Backend contracts used

### Shorts media

The Shorts feed serializer returns both:

- `playback_url`: public processed HLS playback (`master.m3u8`);
- `processed_file_url`: public processed MP4 (`final.mp4`).

Raw media IDs and raw upload objects remain canonical/private media identities
and are never shared. The frontend still calls `create_short_share_link` before
opening the system share sheet so backend share tracking and metrics remain
preserved.

Direct media selection is deliberately permission-aware:

1. only `ready`, `visible`, `audience=everyone` Shorts may expose direct media;
2. when `allow_downloads=true`, the MP4 is preferred;
3. when downloads are disabled, HLS playback is preferred;
4. restricted or incomplete Shorts fall back to the backend `share_url`.

Relevant frontend ownership:

- `ShortModel` parses both processed media URLs;
- `Short.preferredPublicShareUrl` owns the safe URL-selection rule;
- `ShortDetailController` owns share tracking and the platform share action.

### Active Live

The backend exposes the canonical `live_id`, Live metadata, and private LiveKit
session credentials. It does not expose a public MP4, HLS recording, or public
web share URL for active Live sessions. LiveKit `token` and `ws_url` are private
session credentials and must never be shared.

The frontend therefore shares this app deep link:

```text
aos://open/live/room?live_id=<canonical-live-id>
```

Android and iOS register the `aos` scheme. `go_router` resolves the path through
the existing `/live/room` route, which joins through the authoritative backend
API. If AOS is not installed, this custom scheme has no browser/store fallback.
A verified HTTPS universal/app link requires hosted association files and is a
separate backend/web deployment capability.

## Feed “All” hardening

The backend source normalizes missing, blank, and `all` content modes as the
unfiltered feed. The observed deployed/Postman behavior, however, succeeds when
`content_mode=` is explicit while the prior frontend omitted the key. The
frontend now always sends `content_mode`, using an empty string for All.

The Feed tab also previously dropped a new filter load while another request was
active and allowed stale responses to overwrite a later selection. Each initial
load now owns a generation token; category changes supersede prior requests, and
stale initial or pagination results are ignored.

A remaining backend-side explanation is possible if an explicit blank request
still returns only two items: the first-page ranking service chooses a limited
candidate-ID set before the Frappe SQL audience filter runs. Inaccessible ranked
candidates can then be removed after candidate truncation, producing a short
page and `has_more=false`. The relevant authoritative backend locations are
`aos/api/shorts/feed.py` and `infra/search-ranking/app/store.py`. This frontend
iteration does not modify or bypass backend ranking.

## State, errors, and privacy

- One in-flight generation owns the visible Feed result.
- Duplicate/stale filter responses cannot replace the current category.
- Backend share-link failure prevents false share-count success.
- Platform share-sheet failures surface an error and do not expose credentials.
- Restricted Shorts never replace the permission-aware backend link with a
  public object URL.

## Tests

- `test/features/shorts/shared/short_share_target_test.dart`
- `test/features/shorts/shared/data/shorts_feed_api_query_test.dart`
- `test/core/sharing/aos_share_links_test.dart`
- `test/features/live/presentation/live_right_actions_test.dart`

## Validation

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/shorts/shared
flutter test test/core/sharing/aos_share_links_test.dart
flutter test test/features/live/presentation/live_right_actions_test.dart
flutter test
flutter build apk --debug
```

## Delivery

This is **dual delivery**:

- Dart-only Shorts sharing and Feed hardening are Shorebird OTA candidates.
- Android intent filters and the iOS URL scheme require Play Store/App Store
  binaries before shared Live links can reliably reopen the app.
