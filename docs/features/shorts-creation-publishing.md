# Shorts creation and publishing

## Scope

This frontend implements the mobile Shorts workflow from camera/import through local editing, drafts, direct media upload, backend processing, and final metadata publication. Backend contracts remain authoritative.

## Architecture and state ownership

- `ShortRecorderController` owns camera permission, initialization, duration, start/stop, elapsed time, interruption handling, flash, camera switching, and imported media.
- The plugin recorder adapter owns the `camera` import and holds the shared `shorts` camera lease; gallery import uses `MediaAcquisitionService` and app-owned staging.
- `ShortEditorController` owns source media, trim range, selected sound, overlays, draft state, unsaved changes, playback, and export progress.
- `SoundPickerController` and `ShortsSoundsApi` are the single sound-picker path used before recording and from the editor.
- `ShortDraftRepository` owns typed, versioned local drafts and durable app-owned source media.
- `PostShortController` owns the post form, media upload, duplicate-submit protection, and transition into publishing.
- `ShortPublishingCoordinator` owns durable pending publication, processing polling, final metadata application, retry/resume, and cleanup.
- `ShortMentionsController` owns debounced, paginated friend lookup with stale-response protection.

Widgets render explicit controller states and do not own backend workflows.

## Backend contracts

The client follows the current backend sequence:

1. Prepare through the shared media coordinator, then initialize a media upload using purpose `short_video_raw` and an idempotency key.
2. Upload the video directly to the provided MinIO URL while reporting real byte progress.
3. Confirm the media upload.
4. Create the Short using the confirmed raw media ID, audience, comment permission, and download permission.
5. Poll the canonical Short while background video processing runs.
6. Apply caption, hashtags, content mode, optional ad, audience/interactions, and canonical sound metadata only when the Short becomes playable.
7. Keep failed/pending work durable for retry or app restart.

Stable backend error identifiers are preserved by `unwrapFrappe`; HTTP-successful `{ok: false}` envelopes are treated as failures.

## Recording lifecycle

The recorder exposes `initializing`, `ready`, `starting`, `recording`, `stopping`, `recorded`, `permissionDenied`, `unavailable`, and `error` states. Supported design durations are 15 seconds, 60 seconds, and 3 minutes. Progress comes from a `Stopwatch`, recording stops at the selected duration, and duplicate start/stop operations are guarded. Backgrounding stops an active recording and disposes the camera deterministically; resuming reinitializes when appropriate.

Camera and microphone denial, unavailable camera, initialization error, and import fallback each have a reachable UI state.

The recorder UI remains specialized. Its adapter releases the shared camera
lease whenever the controller disposes it on pause, detach, camera switch
failure, or route disposal. It does not change Calls lifecycle or native launch
mode.

## Sound selection

The shared picker uses backend sound listing, cursor pagination, search, favorites, custom sound import where supported, canonical sound IDs, and preview playback. Starting a new preview stops the previous one. The selected ID is retained separately from its display title. Shop content accepts only backend-marked commercial-safe sounds; the backend remains authoritative.

## Editor tools

The editor supports:

- non-destructive start/end trimming with a minimum valid range;
- shared sound replacement;
- text overlays with color;
- emoji/sticker overlays;
- bottom-centered on-video captions;
- dragging, scaling, editing, and removal;
- a bottom-center delete target that deletes only when the drag ends inside its zone;
- export progress and cancellation.

Visual overlays are rendered into the exported video. The original source is not mutated.

## Overlay coordinate model

Overlay centers are stored as normalized `(x, y)` values in `[0, 1]` relative to the visible video canvas. Dragging converts device-space deltas into normalized coordinates and clamps them to safe bounds. Export maps the normalized values to the source video dimensions, so placement remains stable across screen sizes and export resolution.

## Local drafts

Draft metadata is a typed `ShortDraft` with an explicit schema version. It stores the durable source path, trim range, canonical sound metadata, overlays, source dimensions/duration, owner ID, and timestamps. Large media bytes are never placed in SharedPreferences.

Source media is copied into application-support storage. Draft lookup is owner-scoped, missing media is removed safely, abandoned drafts are pruned after 30 days, and unsupported schemas are ignored/cleaned rather than interpreted as current data. Draft existence never implies that a Short was published.

## Mentions

Typing `@` activates debounced backend friend search. Pagination, loading, empty, error, retry, and stale responses are handled. Selection inserts a safe token at the current cursor and retains the canonical account ID in client state.

Current backend limitation: publication accepts mention tokens parsed from caption text and does not expose a structured mention-ID field. Canonical IDs are retained client-side but cannot be submitted separately until that contract exists. Display names are not treated as identity.

## Privacy and interactions

Audience values map only to backend-supported values: `everyone`, `followers`, `friends`, and `only_me`. Comment and download permissions are submitted through their backend fields. The design's “Save to device” control is local-only. No unsupported resharing field is fabricated.

## Upload, publishing, and recovery

The progress UI distinguishes preparation, MinIO transfer, confirmation, publishing, processing, ready, and failed states. MinIO transfer progress uses actual sent/total bytes. Duplicate Post taps are blocked.

After a canonical Short ID exists, a `PendingShortPublication` is persisted before background processing continues. Authenticated startup resumes matching owner jobs. Source/export media and draft files are removed only after metadata publication succeeds.

Retry uses the existing canonical Short ID and backend `retry_processing` capability. Cancelling is offered only before a Short ID exists and only cancels the active transfer.

Known backend limitation: media initialization is idempotent, but `create_short` has no client idempotency field. A connection loss after backend creation but before the response cannot be made perfectly duplicate-safe by the frontend alone.

## Errors and offline behavior

Network, backend-envelope, validation, media, permission, export, processing, and missing-file failures remain explicit. Failed uploads preserve the draft/source for retry. Pending processing survives normal navigation and app restart. No arbitrary delay is used for state coordination; the only delay is bounded backend processing polling.

## Accessibility and responsive behavior

Changed controls include semantics for recording, elapsed time, selected duration, sounds, trim range, overlays, delete target, privacy selection, and publishing progress. Recorder/editor surfaces use SafeArea, scrollable lower controls, bounded video canvases, keyboard-aware sheets, wrapping, and normalized overlays. Device validation must still cover TalkBack/VoiceOver, 200% text scale, RTL, landscape, and smallest supported screens.

## Tests

Focused tests cover:

- Frappe failure-envelope mapping;
- recording limits and trim validation;
- overlay, draft, and pending-publication serialization;
- mention detection and cursor insertion;
- upload-state defaults and privacy/interactions;
- existing Shorts feed/share regressions.

Camera, export, MinIO, and complete navigation remain device/integration checks because they depend on plugins and real media services.

## Validation

Run from the frontend project root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test
flutter test test/core/api/api_response_test.dart
flutter test test/features/shorts/create_short
flutter test test/features/shorts
flutter build apk --debug
```

The camera and video-export plugins already belong to the supplied dependency
graph. This media-boundary migration does not change `pubspec.yaml` or
`pubspec.lock`.

## Delivery and rollback

This migration changes Dart, tests, and documentation only and is therefore a
**Shorebird OTA candidate**, subject to analyzer, test, and device validation on
the exact release baseline. Draft and pending-publication files remain versioned
and can be ignored safely by an older build, but rolling back during an active
local edit can leave app-support media for later pruning.
