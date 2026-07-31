# Ad Detail Gallery Download

## Scope

The download action in the ad-detail full-screen image viewer now saves the currently visible image directly to the device gallery. It no longer opens the `share_plus` sheet.

The shared service also supports video files so the same download path can be reused when a dedicated ad-video download action is exposed.

## Architecture and ownership

- `FullScreenImageViewer` owns only UI state: selected image, loading state, success feedback, and duplicate-tap prevention.
- `AdImageExportService` owns URL resolution, permission checks, network download, temporary-file lifecycle, gallery persistence, and stable failure mapping.
- `GalAdGalleryWriter` is the native gallery boundary and is injected so service behavior can be tested without platform channels.
- Backend contracts are unchanged. Media URLs continue to come from the existing ad-detail response and are resolved through `buildFileUrl`.

## Permissions and privacy

- iOS uses the existing `NSPhotoLibraryAddUsageDescription` and `NSPhotoLibraryUsageDescription` entries.
- Android gallery writes on API 29 and below use `WRITE_EXTERNAL_STORAGE` restricted with `android:maxSdkVersion="29"`; newer Android versions use scoped media storage through the plugin.
- Gallery access is requested only after the user taps download.
- Downloaded temporary files are deleted after success or failure. Stale AOS gallery-download files are cleaned before the next attempt.

## UI states

- The download button becomes a progress indicator while work is active.
- Repeated taps are ignored until the active operation finishes.
- Success shows a localized “Image saved to gallery” message.
- Permission, network, missing-media, unsupported-format, storage-space, and native-platform failures produce visible errors.

## Tests

- image download, gallery save, and temporary-file cleanup;
- permission request and denial;
- video-capable shared service path;
- HTTP 404 error mapping;
- localized download semantics and 200% text-scale overflow safety.

## Validation

```bash
flutter pub get
flutter gen-l10n
dart format lib test
dart analyze
flutter test test/features/home
flutter build apk --debug
```

## Delivery

**Play Store/App Store release required.** The change adds the native `gal` plugin; it is not a Shorebird-only Dart update.
