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

- caption with inline `@` mention suggestions;
- a full-width hashtag action and seamless hashtag picker;
- audience;
- comments/downloads/local-save options;
- selected sound controls;
- optional seller product tagging;
- compact duration/visibility/comment/download badges.

Tapping Post immediately navigates back to Feed while upload continues through the retained upload session provider.

Mention selection is intentionally caption-only: typing `@` in the caption opens the mention suggestions. There is no separate Mention action beside Hashtags. The hashtag picker owns its `TextEditingController` for the lifetime of the modal widget and commits additions/removals immediately, so closing the sheet cannot leave a disposed controller attached to a `TextField`.

Flutter 3.44 adds a debug assertion when a `ListTile` is separated from its nearest `Material` by an opaque decorated surface. Inline mention suggestions therefore use their own `Material` surface so ink/background painting remains valid.

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

## September 2026 publish-screen and analytics hardening

The Publish Short screen keeps one Riverpod owner for mention search for the
lifetime of a publishing session. The provider is `autoDispose.family` keyed by
the publishing session ID. Inline `@` lookup is the single mention-entry surface and uses the session-scoped
controller for the lifetime of the Publish Short screen. The separate Mention
action/sheet was removed so mention insertion happens only from caption context.
Hashtag editing owns its `TextEditingController` for the full sheet lifecycle and
updates the publishing controller without disposing a controller still referenced
by a closing `TextField`. This avoids modal lifecycle races and duplicate mention UX.

On phone layouts the media preview and caption composer now share the first row
instead of stacking a large 9:16 preview over the form. Duration, audience,
comment permission, and download permission are rendered as small translucent
overlays on the preview. The Hashtag action uses the full action space below the caption; mentions are
inserted through inline `@` search in the caption itself. Wider layouts preserve
the existing adaptive two-column treatment.
All lower settings remain scrollable and keyboard reachable.

### Upload retry and diagnostics

The working direct/multipart upload architecture is preserved. Multipart retry
continues to use the original media-init idempotency key and backend
`multipart_status` as storage truth. Whenever status is reconciled, confirmed
`uploaded_bytes` are immediately reported to the UI before another part is
sent. A retry therefore returns to the backend-confirmed percentage instead of
pretending that confirmed multipart work was lost. After the part-level retry
budget is exhausted, network/timeout/rate-limit/server failures get a bounded
status reconciliation so parts already accepted by storage are not discarded.
The controller also retains the last visible progress while reinitializing an
ordinary retry.

Safe warning logs identify the failing stage, Dio/failure type, HTTP status, and
stable backend error ID where available. Signed MinIO URLs, query signatures,
auth headers, and file contents are never logged. Cancellation still increments
the logical upload operation version so a user-requested abort does not reuse
that abandoned operation.

### Per-Short analytics

Owner Manage -> View analytics consumes the backend
`get_short_analytics(short_id, date_from?, date_to?)` contract. The modal shows
current lifetime Views, Likes, Comments, Shares, Saves, and Reposts, followed by
period Impressions, Downloads, average watch time, completion rate, and
engagement rate. Initial loading, retry, refresh-in-place, and refresh failure
states are explicit. Refresh retains the last successful values and suppresses
stale request completion.

The frontend does not calculate or invent analytics. Values come from backend
`current_totals` and date-ranged `totals`; the backend remains authoritative for
access, aggregation, date windows, and rate limits.

### Focused validation

Run in addition to the full frontend suite:

```bash
flutter test test/features/shorts/analytics/data/shorts_analytics_models_test.dart
flutter test test/features/shorts/create_short/presentation/post_short_details_helpers_test.dart
flutter test test/features/shorts/contracts/shorts_hardening_source_contract_test.dart
```

Device validation must include selecting/removing hashtags, modal and inline
mentions, smallest-phone publish layout, keyboard-open layout, 200% text scale,
RTL, interrupted multipart retry, explicit upload cancellation, and owner
analytics initial/refresh/error states.

## Short detail final polish

Short detail keeps backend engagement and permission decisions authoritative while using mobile-native presentation for sharing, sound reuse, save state, and comment deletion.

### Custom share surface

The Short action rail and owner/manage share action now open the in-app `ShortShareSheet` instead of opening `share_plus` directly. The sheet preserves the visible Short behind a translucent modal barrier rather than replacing it with a black system-share background.

The sheet provides:

- Short preview and verified-creator indicator;
- recent AOS conversations from the existing conversations provider;
- multi-conversation selection and an optional message;
- `share_short_to_chat` for AOS chat delivery with a distinct event ID per conversation;
- repost, report, and save-video shortcuts backed by the existing callbacks;
- WhatsApp, Facebook, X, email, and copy-link actions;
- backend-supported share-link channels only. X and email use the backend `system_share` channel because the backend does not define separate `x` or `email` share-channel enums;
- one in-flight action at a time to prevent repeated submissions.

The share sheet does not duplicate chat creation, delivery, permissions, visibility, download eligibility, repost eligibility, or reporting rules.

### Short creator and sound presentation

`ShortBottomInfo` now renders the backend verified flag beside the creator name and always renders the audio row as the final metadata row. Shorts without a reusable sound are labelled as original audio; reusable sounds show the canonical title and artist.

The right-side action rail now includes Save as a first-class action, uses a more compact icon footprint, sits slightly farther toward the screen edge, and ends with a rotating sound-disc action. The rotation honors the platform reduced-motion/disable-animation preference while the action remains fully tappable.

Opening the sound action:

- shows an informational dialog for original audio;
- shows reusable sound metadata and an optional audio preview when a file URL is available;
- loads a compact `sound_shorts` thumbnail strip for reusable sounds without inventing a separate recommendation source;
- exposes `Use this sound` only for non-original reusable sounds.

`Use this sound` navigates through the existing named Post Short route with the canonical `ShortSound` as route `extra`. `PostShortMediaPickerScreen` initializes its existing sound owner from that value, so recording/import starts with the selected sound already chosen. The normal route/redirect layer remains in control; the sound dialog does not bypass auth/navigation policy with a raw screen push. When a sound is explicitly supplied, the recorder does not immediately offer an unrelated saved draft over that selection.

### Comment and reply deletion

The existing backend `delete_comment` lifecycle, `canDelete`/owner permission fields, pending-delete state, and controller rollback/error handling are preserved. The visible Delete text is replaced by a compact trash icon beside the favorite action. Replies reuse the same `CommentMainRow`, so comments and replies receive the same pending/deletion affordance without a second deletion implementation.

### Validation for Short detail polish

Run:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/shorts/contracts/shorts_hardening_source_contract_test.dart
flutter test test/features/shorts
flutter test
flutter build apk --debug
```

Device coverage should include:

- share sheet over portrait and landscape Shorts with the underlying Short still visible;
- recent chats loading/error/empty states and multi-chat send;
- repeated taps while sending or opening an external share target;
- copy link, WhatsApp, Facebook, X, and email with and without target apps installed;
- verified/unverified creators;
- original and reusable sound dialogs;
- reusable sound preview failure without blocking `Use this sound`;
- `Use this sound` opening the recorder with the selected sound label already present;
- comment and reply delete permission, pending, success, and backend failure;
- save/unsave from the right action rail;
- 200% text scale, RTL, small screens, landscape, light/dark mode, and no overflow.

No dependency, native platform, permission, asset, or backend change is included by this Short detail polish. It remains a **Shorebird OTA candidate** after analyzer/test/device validation.

### Final Share branding and owner deletion

The in-app Short share row uses the existing locked `font_awesome_flutter`
package for the WhatsApp, Facebook, and X brand glyphs. Brand treatments use
WhatsApp green (`#25D366`), Facebook blue (`#1877F2`), and the black/white X
mark. Gmail uses an inline multicolor SVG mark through the already-installed
`flutter_svg` package, so no new asset or dependency is introduced. External
share transport remains unchanged and still uses the backend-supported share
channels plus the existing `url_launcher` destinations.

Owner Manage continues to expose **View analytics** only inside the owner UI.
The backend remains authoritative and independently requires authentication and
either Short ownership or staff Report permission for `get_short_analytics`.

**Delete short** is now shown directly below View analytics only when the Short
is owner-viewed and backend-derived `canDelete` is true. The destructive action
requires an explicit confirmation, then calls the existing
`delete_short(short_id)` endpoint through `ShortsManagementApi`. Backend delete
semantics remain authoritative: the endpoint re-checks login and ownership and
performs the existing soft-delete/processing-job/media-release lifecycle. After
a successful response the primary Shorts feed is refreshed and Short Detail is
closed; backend errors are surfaced without pretending deletion succeeded.

Focused validation:

```bash
flutter test test/features/shorts/feeds/application/short_deletion_coordinator_test.dart
flutter test test/features/shorts/contracts/shorts_hardening_source_contract_test.dart
dart analyze
```
