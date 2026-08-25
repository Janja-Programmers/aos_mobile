# Media Acquisition, Preparation, and Upload

## Purpose

All user-selected media crosses one core boundary before feature code can use
it. The boundary prevents feature-specific picker behavior, unbounded image
decoding, unsafe temporary paths, competing camera owners, and inconsistent
upload error handling.

The backend remains the source of truth for accepted upload purposes, final
validation, permissions, storage, processing, and canonical media records.
Frontend policies are early UX checks only; they never expand a backend
capability.

## Layers and ownership

| Layer | Owner | Responsibility |
| --- | --- | --- |
| Policy | `MediaPolicies` | Use-case kind, extension, count, size, image bounds, camera facing, capture duration, and backend purpose |
| Acquisition | `MediaAcquisitionService` | Camera, gallery, document, audio, video, media, and generic-file intents |
| Plugin adapters | `core/media/data/adapters` | The only normal imports of picker/compression plugins |
| Staging | `MediaFileStagingService` | Immediate copy from provider/plugin cache into app-owned temporary storage |
| Preparation | `MediaPreparationService` | Signature detection, type/size validation, native bounded image compression, orientation normalization, and EXIF removal |
| Camera resources | `MediaCameraResourceCoordinator` | One lease across shared capture, Shorts, and Live |
| Upload | `MediaUploadCoordinator` | Preparation, stage/progress mapping, cancellation, bounded batch work, per-item failures, and transport delegation |
| Transport | `MediaUploadApi` | Backend `init_upload`, signed object-store PUT, and `confirm_upload` |

Feature widgets select a `MediaUseCase`; they do not configure plugin options or
invent upload-purpose strings.

## Standard flow

```text
feature intent
→ MediaUseCase policy
→ approved picker/camera adapter
→ app-owned staging copy
→ signature and policy validation
→ native bounded preparation when image
→ MediaUploadApi backend contract
→ canonical MediaUploadResult
→ explicit temporary-file cleanup
```

Search by image and chat wallpaper stop after preparation because they do not
create a canonical uploaded-media record through the normal upload contract.

## Acquisition and lost-result recovery

Camera capture is in-app and uses the existing `camera` dependency. It does not
start the external `image_picker` camera activity. This preserves Android's
CallKit-required `singleInstance` launch mode and avoids the activity-result
restart that previously appeared after a camera was open for several seconds.

Gallery image/video selection stays behind `ImagePickerMediaAdapter`. Before a
picker launch it records the owning `MediaUseCase`; a later invocation for the
same use case calls `retrieveLostData` before opening a new picker. Selected
provider/cache files are copied immediately into AOS staging. FilePicker paths
are staged by the same rule. Explicit success, removal, cancellation, and
disposal paths delete owned files; a best-effort age-based prune removes stale
staging files left by process death.

No feature may retain an external provider path as its durable source.

## Preparation rules

Preparation reads only a small signature header in Dart. Images are then
resized/compressed by the native image-compression adapter, not decoded as a
full bitmap on the Dart heap. Prepared photo output is bounded JPEG with
orientation applied and EXIF removed. Verification uses a higher-resolution,
higher-quality policy to preserve document legibility. PDFs and supported
audio/video/document files remain byte streams and are not decoded in memory.
Transformable image inputs also have an explicit source-size ceiling before
native preparation; the smaller backend limit is applied to the prepared file.
HEIC/HEIF is accepted only as a transformable local image source and is never
sent directly; preparation converts it to backend-supported JPEG. Formats that
are not transcoded use the backend allowlists exactly: MP4/MOV/M4V video,
MP3/M4A/AAC/WAV/OGG audio, and PDF documents.

Thumbnail widgets must set `cacheWidth`/`cacheHeight` appropriate to their
rendered size. Full source resolution is not required for an 80-pixel preview.

## Camera resource contract

`MediaCameraResourceCoordinator` allows one non-call owner:

- `sharedCapture` for Ads, Search, Reviews, Profile, Live cover,
  Verification, Seller, and Chat;
- `shorts` for the specialized Shorts recorder;
- `live` for LiveKit preview/publication.

The shared camera and Shorts release their leases on inactive, paused,
detached, disposal, and editor-navigation paths. Go Live releases its prepared
LiveKit camera before opening the shared cover camera and reacquires the preview
afterward.
Live camera prepare/release/flip transitions are serialized, so a cover-camera
request cannot overlap an in-flight LiveKit camera start.
`LiveMediaService.releaseCamera` releases the Live lease in `finally`.

This contract does not own, modify, or observe Calls. CallKit, Calls state,
`MainActivity`, Android launch mode, and native incoming-call recovery remain
unchanged. App lifecycle interruption causes Flutter camera owners to release
their resources so the validated Calls lifecycle remains authoritative.

## Upload semantics

`MediaUploadCoordinator` is the standard feature-facing upload entry point. It
preserves the backend sequence and supports:

- preparation, initializing, transfer, and confirmation stages;
- actual sent/total byte progress;
- Dio cancellation;
- caller-provided idempotency keys;
- at most two concurrent uploads in the default batch path;
- indexed failures rather than silently dropping failed media;
- best-effort rollback of successful batch items when another item fails.

The final prepared-file limits mirror the backend purpose registry: 10 MB ad,
review, seller, and Live-cover images; 5 MB profile images; 20 MB verification
media; 50 MB chat attachments and sound uploads; 200 MB ad videos; and 300 MB
raw Shorts videos. Backend validation remains authoritative.

Shorts retains its specialized publish state machine, durable pending job,
progress UI, and cancellation token. It calls the shared upload coordinator for
the raw-video upload instead of replacing its UI/controller lifecycle.

## Migrated feature matrix

| Feature | Sources | Policy / transport |
| --- | --- | --- |
| Ads | Shared photo/video camera, multi-image gallery, video gallery | `ad_image`, `ad_video` |
| Search by image | Shared photo camera, image gallery | Prepared image to existing search endpoint |
| Reviews | Shared photo camera, multi-image gallery | Five-image policy and atomic batch behavior |
| Profile | Shared photo camera, image gallery | `profile_image` then canonical profile update |
| Live cover | Shared photo camera, image gallery | `live_cover`; specialized LiveKit preview preserved |
| Verification | Shared front/rear photo camera, image gallery, documents | `verification_document` |
| Seller | Shared photo camera, image gallery | `seller_banner` |
| Chat | Shared photo camera, image gallery, generic file/document, audio | `chat_attachment` |
| Chat wallpaper | Image gallery | Prepared local app-support copy |
| Shorts | Specialized recorder, shared gallery video adapter | `short_video_raw` and existing publish lifecycle |
| Shorts sounds | Shared audio file adapter | `sound_upload` |

## Extension rules

1. Add or update a `MediaUseCase` policy before adding a feature picker.
2. Add plugin behavior only inside an approved adapter.
3. Return `AcquiredMedia`, not an unowned plugin path.
4. Use `MediaPreparationService` for local-only consumers and
   `MediaUploadCoordinator` for uploads.
5. Define who discards the staged source on success, failure, removal, and
   widget/controller disposal.
6. Do not change Android launch mode to accommodate a picker.
7. Do not create a second Shorts recorder, LiveKit owner, Calls owner, or raw
   upload implementation.

## Tests

`test/core/media` covers policy-to-backend mappings, content-signature
detection, single-owner camera leases, retired helpers, feature upload
bypasses, and plugin import boundaries. The source-contract allowlist contains
only the core adapters and the specialized Shorts camera adapter.

Run:

```bash
dart format lib test
dart analyze .
flutter test test/core/media
flutter test test/features/shorts/create_short
flutter test test/features/live
flutter test test/features/connect/chats
flutter test
```
