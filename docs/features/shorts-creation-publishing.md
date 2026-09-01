# Shorts creation and publishing

## Scope

This document covers the Flutter Shorts creation, upload, metadata-edit, and sound-edit flows. Backend contracts are authoritative; the frontend mirrors limits only for UX and does not own classification, permissions, moderation, or state transitions.

## Architecture and state ownership

- `ShortRecorderController` owns camera permission, camera lifecycle, recording duration, microphone enable/disable, flash, camera switching, elapsed time, and gallery import.
- `PluginShortCameraDriver` is the camera-package adapter and holds the shared Shorts camera lease. `CameraController(enableAudio: ...)` is recreated when the microphone setting changes.
- `ShortEditorController` owns trim, overlays, selected sound, draft state, playback, export, and unsaved changes.
- `PostShortController` owns selected upload media, caption/hashtags, audience, interaction settings, optional product tag, selected sound, duplicate-submit protection, upload progress, cancellation, and Short creation.
- `MediaUploadCoordinator` remains the shared preparation/upload boundary. Shorts pass truthful duration metadata and request `upload_mode=auto`.
- `MediaUploadApi` owns direct PUT and resumable multipart transport details.
- `ShortPublishingCoordinator` owns post-processing polling, final metadata publication, durable pending publication, and cleanup.
- `ShortsSoundsApi` owns post-publication `change_short_sound` and `remove_short_sound` calls.

Widgets render controller state and do not make backend classification decisions.

## Backend contracts

### Media admission and upload

For `purpose=short_video_raw`, the frontend submits:

- `filename`
- `content_type`
- exact `size_bytes`
- real `duration_seconds`
- `upload_mode=auto`
- a logical-operation idempotency key

The backend accepts up to 300 MiB and 600 seconds. The frontend rejects a missing/non-positive duration and a duration above 600 seconds before transfer, but the backend remains authoritative.

The backend chooses one of two upload modes:

1. `direct`: PUT to the returned whole-object URL, then call `confirm_upload`.
2. `multipart`: reconcile with `multipart_status`, request bounded part URLs, upload exact byte ranges with bounded parallelism, reconcile again, then call `complete_multipart_upload`. Multipart completion already performs media confirmation.

A user cancellation before Short creation cancels the active byte transfer. Multipart cancellation also calls backend abort best-effort. The next explicit retry uses a new logical upload idempotency key after cancellation.

### Short creation and sound

After media upload completes, `create_short` receives the confirmed raw media ID plus audience/comment/download settings. A selected reusable sound is attached at `create_short` time so the backend can include it in the first processing generation rather than forcing a second audio-only processing pass.

### Metadata publication and classification

After the video becomes playable, `update_short_metadata` receives caption, hashtags, audience, interaction settings, optional `ad_id`, and any required sound metadata. The frontend does **not** send `content_mode` as authoritative input. The backend owns automatic Shop/Geo/Vibes/Learn classification.

A validated owned active `ad_id` is optional seller commerce context. Supplying an empty `ad_id` on an edit explicitly detaches the product. Non-sellers do not see product tagging UI.

Metadata edits can hide the Short and requeue moderation according to backend rules. The frontend does not fabricate a local moderation state.

### Change/remove sound

Owners with backend permission can:

- change sound via `change_short_sound` using canonical sound ID, start offset, duration, and volume;
- remove sound via `remove_short_sound`.

When a metadata edit and a new sound are submitted together, the frontend uses `update_short_metadata` with the new sound so backend classification/sound validation and audio reprocessing remain coordinated. Sound removal uses the dedicated remove endpoint.

## Recorder UI

Supported recording limits are:

- 15 seconds
- 60 seconds
- 10 minutes

The recorder exposes a microphone toggle before recording. Turning the microphone off recreates the camera controller with audio disabled, so the recorded video contains no microphone track from the camera plugin. If microphone permission is denied, the user can choose to continue recording without microphone permission.

Recorder lifecycle remains deterministic: duplicate start/stop calls are ignored, backgrounding disposes the camera, an active recording is stopped before suspension, and resume reinitializes when appropriate.

## Editor

The editor preserves the existing trim, text, sticker, caption, drag/scale/delete, playback, draft, and export behaviors. The close action now asks for confirmation before destructive discard. Selected sound controls allow start position, segment duration, volume, and removal.

Exported media carries the editor-selected duration into `SelectedMedia`; upload therefore uses the measured edited duration instead of fabricating a value later.

## Publish screen

The publish screen is responsive and keeps the video preview prominent while reducing duplicated controls. It provides:

- caption and mentions;
- hashtags;
- audience;
- comments/downloads/local-save options;
- selected sound controls;
- optional seller product tagging;
- compact duration/visibility/comment/download badges.

Tapping Post immediately navigates back to Feed while upload continues through the retained upload session provider.

## Upload progress UI

Feed shows a compact upload card with:

- current stage;
- local filename;
- byte percentage while transferring;
- determinate/indeterminate progress;
- Cancel during initialization/transfer;
- Retry after cancellation/failure;
- dismiss after transfer is no longer active;
- ready state that can open the Short detail.

The transfer is not blocked by the publishing screen remaining mounted.

## Metadata editing UI

An owner with `canEdit` gets an Edit Short action on Short detail. The sheet supports:

- caption;
- hashtags;
- audience;
- comments/downloads;
- sound change/remove and sound controls;
- optional active product tagging for sellers.

Canonical IDs remain separate from display titles. Stable backend failures are shown to the user without branching on message text.

## Persistence and offline behavior

Draft and pending-publication persistence from the existing implementation are preserved. Processing/publishing can continue after leaving the creation screen.

Current limitation: multipart transport can reconcile and retry parts within the active process, but this patch does not add a new durable multipart-session store for process-death recovery. The backend contract supports durable resume using `media_id` plus a same-file fingerprint; implementing that persistence layer remains a separate production-hardening item if process-death resumability is required before release.

## Security and privacy

- No signed upload URL, multipart upload ID, or part ETag is persisted by this patch.
- Product ownership/activity and commercial-safe sound rules remain backend-authoritative.
- Camera and microphone permissions are requested only for the selected recording mode.
- No backend endpoint, enum, permission, classification rule, or default is invented.

## Accessibility and responsive behavior

Changed controls use SafeArea, scrollable/keyboard-aware sheets, wrapping duration controls, bounded preview sizes, semantic labels for recording/microphone/edit actions, and live regions for important errors. Device validation should cover TalkBack/VoiceOver, 200% text scale, RTL, small screens, landscape, keyboard-open sheets, light/dark mode, and no RenderFlex overflow.

## Automated tests

Focused tests in this patch cover:

- 15s / 60s / 10m recording limits;
- microphone-enabled default and microphone toggle contract;
- recorder duplicate start/stop behavior;
- upload state no longer requiring client-owned Shop classification;
- direct and multipart media-contract parsing;
- existing trim and overlay serialization behavior.

Existing Shorts tests should also be run because shared media and recorder interfaces changed.

## Validation

Run from the frontend project root after applying the patch:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/core/media/media_upload_result_test.dart
flutter test test/features/shorts/create_short
flutter test test/features/shorts
flutter test
flutter build apk --debug
```

Flutter/Dart are not available in the packaging environment used to prepare this patch, so these commands are intentionally left for the device/build environment and are not claimed as passed.

## Device checks

At minimum verify:

- camera with mic on/off, including microphone denied + camera allowed;
- 15s, 60s, and 10m selection and auto-stop;
- imported clips near and over 10 minutes;
- small and large direct uploads;
- multipart upload over Wi-Fi/mobile-data changes;
- cancel then retry;
- background/foreground during upload;
- selected sound, sound trim/volume, remove/change sound;
- seller and non-seller publish screens;
- attach/detach active product;
- metadata edit and re-moderation behavior;
- small screen, landscape, keyboard open, RTL, 200% text scale, light/dark mode;
- no overflow/clipped actions.

## Delivery and rollback

No dependency, SDK, permission, native platform, asset, or storage-schema change is included. This is a **Shorebird OTA candidate**, subject to analyzer/test/device validation against the exact release baseline.
