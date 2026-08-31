# Media Acquisition, Preparation, and Upload

## Purpose

All user-selected media crosses one core boundary before feature code can use
it. The boundary prevents feature-specific picker behavior, unbounded image
decoding, unsafe provider/cache paths, competing camera/picker owners, and
inconsistent upload error handling.

The backend remains the source of truth for accepted upload purposes, final
validation, permissions, storage, processing, and canonical media records.
Frontend policies are early UX checks only; they never expand a backend
capability.

## Layers and ownership

| Layer | Owner | Responsibility |
| --- | --- | --- |
| Policy | `MediaPolicies` | Use-case kind, extension, count, size, image bounds, camera facing, capture duration, and backend purpose |
| Acquisition | `MediaAcquisitionService` | Camera, gallery, document, audio, video, media, and generic-file intents |
| Picker operation ownership | `MediaPickerOperationCoordinator` | One external picker/result channel at a time across photo library and file browser |
| Plugin gateway | `PluginImagePickerGateway` | Official `image_picker` API plus Android Photo Picker configuration |
| Plugin adapters | `core/media/data/adapters` | The only normal imports of picker/compression plugins |
| Staging | `MediaFileStagingService` | Immediate copy from provider/plugin cache into app-owned temporary storage |
| Preparation | `MediaPreparationService` | Signature detection, type/size validation, native bounded image compression, orientation normalization, and EXIF removal |
| Camera resources | `MediaCameraResourceCoordinator` | One lease across shared capture, Shorts, and Live |
| Upload | `MediaUploadCoordinator` | Preparation, stage/progress mapping, cancellation, bounded batch work, per-item failures, and transport delegation |
| Transport | `MediaUploadApi` | Backend `init_upload`, signed object-store PUT, and `confirm_upload` |

Feature widgets select a `MediaUseCase`; they do not configure plugin options,
Android picker behavior, or upload-purpose strings.

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

## Android photo picker and activity contract

AOS uses Flutter's endorsed `image_picker` package for photo/video library
selection. Its Android implementation is explicitly configured with
`useAndroidPhotoPicker = true`, so Android 13+ uses the platform Photo Picker
and supported older Android devices prefer the AndroidX Photo Picker path with
its platform/OEM/document-provider fallbacks. AOS does not request full image
metadata for normal gallery image selection.

`MainActivity` uses `android:launchMode="singleTask"`. `singleInstance` is not
compatible with result-returning picker activities: it isolates the root
activity into another task and causes `image_picker` results to be returned as
cancelled. `singleTask` keeps one root AOS activity while allowing the system
Photo Picker/file browser to return a result normally.

The manifest change in this hardening is intentionally limited to
`singleInstance` → `singleTask`. Other Android permissions and native call code
are outside this media change.

## Acquisition, staging, and process-death recovery

Gallery image/video selection is split into two responsibilities:

- `PluginImagePickerGateway` owns the plugin API and Android Photo Picker
  configuration.
- `ImagePickerMediaAdapter` owns AOS lifecycle, recovery, staging, and
  use-case association.

Before opening the photo library, AOS persists a small request journal containing
an operation ID, `MediaUseCase`, media kind, item limit, and start timestamp. It
never stores media bytes, authentication data, or backend identifiers in this
journal.

At app bootstrap, `MediaAcquisitionService.initialize()` triggers Android
`retrieveLostData()`. If Android destroyed the Flutter activity while the
picker was open, the recovered provider/cache files are immediately copied into
AOS-owned staging and recorded in a bounded recovery queue. The queue is scoped
by original use case and media kind, survives another process restart, and is
consumed before a new picker is opened for the same operation type. Recovery
records older than one day, missing files, and excess queued batches are cleaned
up. The normal staging age-prune remains the final safety net.

This makes these states explicit:

```text
picker requested
→ request journal persisted
→ system picker opened
→ cancel: journal cleared, no media returned
→ success: provider file staged, journal cleared
→ process death: journal remains
→ next app bootstrap: retrieveLostData → stage → recovery queue
→ matching feature acquisition: recovered media returned before new picker
```

Provider/cache paths are never treated as durable feature state.

File/document/audio selection remains behind `FilePickerMediaAdapter`, stages
successful results immediately, and shares `MediaPickerOperationCoordinator`
with the photo library so two external result-returning activities cannot
compete. `file_picker` does not expose an `image_picker`-equivalent Android
lost-result recovery API, so process-death recovery for arbitrary documents is
a known plugin limitation rather than fabricated frontend behavior.

## External picker concurrency

Only one external picker may own the Android/iOS result channel at a time.
`MediaPickerOperationCoordinator` issues a lease to either the photo library or
file browser and rejects a second overlapping acquisition. The lease is always
released in `finally`, including cancellation and exceptions. This protects
repeated taps and cross-feature races without arbitrary delays.

## Camera resource and captured-preview lifecycle

Camera capture stays in-app using the existing `camera` dependency. It does not
use `ImageSource.camera`; all still-camera consumers therefore share the same
camera-resource contract and UI.

After a photo or video is captured, the capture screen now follows this order:

```text
capture bytes
→ set captured file as review source
→ render one stable review frame
→ dispose/release CameraController
→ enable Retake / Use
→ on Use: stage into AOS-owned temporary storage
→ delete raw camera cache file
```

The review actions, close action, and back navigation are disabled while the
capture is transitioning. This prevents rendering `CameraPreview` against a
controller that is being disposed and removes the brief transient error frame
previously observed after taking a profile photo. Controller disposal is
best-effort logged and cannot invalidate an already captured file.

`MediaCameraResourceCoordinator` continues to allow one non-call owner:

- `sharedCapture` for Ads, Search, Reviews, Profile, Live cover,
  Verification, Seller, and Chat;
- `shorts` for the specialized Shorts recorder;
- `live` for LiveKit preview/publication.

The shared camera and Shorts release their leases on inactive, paused,
detached, disposal, and editor-navigation paths. Go Live releases its prepared
LiveKit camera before opening the shared cover camera and reacquires the preview
afterward. Live camera prepare/release/flip transitions remain serialized.

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

## Display decode policy

Display decoding is owned by `lib/shared/images/app_image_decode.dart`. It is
separate from acquisition, preparation, cropping, and upload: decode bounds
only affect the in-memory image used to render a widget and never replace or
modify the staged/source file sent to an editor or backend.

`AppImageDecode` converts finite logical layout dimensions to physical pixels
using the current device pixel ratio and applies a 2048-physical-pixel ceiling
for the shared thumbnail/preview policy. Provider-based avatars and local
previews use the shared bounded decode helpers. Full-screen zoom/editor surfaces
remain explicit reviewed exemptions.

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
| Ads | Shared photo/video camera, multi-image Photo Picker, video Photo Picker | `ad_image`, `ad_video` |
| Search by image | Shared photo camera, Photo Picker | Prepared image to existing search endpoint |
| Reviews | Shared photo camera, multi-image Photo Picker | Five-image policy and atomic batch behavior |
| Profile | Shared photo camera, Photo Picker | `profile_image` then canonical profile update |
| Live cover | Shared photo camera, Photo Picker | `live_cover`; specialized LiveKit preview preserved |
| Verification | Shared front/rear photo camera, Photo Picker, documents | `verification_document` |
| Seller | Shared photo camera, Photo Picker | `seller_banner` |
| Chat | Shared photo camera, Photo Picker, generic file/document, audio | `chat_attachment` |
| Chat wallpaper | Photo Picker | Prepared local app-support copy |
| Shorts | Specialized recorder, shared Photo Picker video adapter | `short_video_raw` and existing publish lifecycle |
| Shorts sounds | Shared audio file adapter | `sound_upload` |

## Extension rules

1. Add or update a `MediaUseCase` policy before adding a feature picker.
2. Add plugin behavior only inside an approved adapter/gateway.
3. Return `AcquiredMedia`, not an unowned provider/plugin path.
4. Use `MediaPreparationService` for local-only consumers and
   `MediaUploadCoordinator` for uploads.
5. Define who discards the staged source on success, failure, removal, and
   widget/controller disposal.
6. Do not introduce feature-specific gallery packages or broad-media access to
   work around shared lifecycle defects.
7. Keep one root activity model compatible with result-returning system pickers.
8. Do not create a second Shorts recorder, LiveKit owner, Calls owner, or raw
   upload implementation.

## Tests

`test/core/media` covers policy-to-backend mappings, content-signature
detection, single-owner camera leases, external-picker leases, Android picker
source boundaries, process-death recovery, staging, retired helpers, feature
upload bypasses, and plugin import boundaries.

`test/core/media/media_android_lifecycle_contract_test.dart` protects the
`singleTask` manifest contract, explicit Android Photo Picker configuration,
startup recovery wiring, and captured-preview-before-camera-disposal ordering.

Run:

```bash
flutter pub get
dart format lib test
dart analyze .
flutter test test/core/media
flutter test test/app/bootstrap/app_bootstrap_controller_test.dart
flutter test test/shared/images
flutter test test/platform/android_adaptive_window_contract_test.dart
flutter test test/features/shorts/create_short
flutter test test/features/live
flutter test test/features/connect/chats
flutter test
flutter build apk --debug
```
