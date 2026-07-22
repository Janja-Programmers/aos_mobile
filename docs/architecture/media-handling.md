# Media Handling

## Upload architecture

Core media upload code exposes initialization, upload, confirmation, deletion, and background-removal operations. Feature controllers consume these services for ads, verification documents, profile media, Shorts, chat attachments, reviews, and seller customization.

The frontend depends on server-provided upload URLs and headers. Tests must sanitize signed URLs and assert that client code does not log or persist upload signatures longer than required.

## Local acquisition and editing

The project uses image/file pickers, image cropper, Flutter image compression, the `image` package, video thumbnail generation, audio recording/playback, and platform permissions. Media helpers centralize several acquisition/upload flows, but feature-specific behavior remains in ads, chat, Shorts, reviews, Live, and verification code.

## Display and playback

- `cached_network_image` is used for network image display/caching.
- `video_player` and `chewie` support video playback.
- `photo_view` supports image inspection.
- `just_audio` and `audioplayers` support audio flows.
- `livekit_client` powers call and live media tracks.

## Lifecycle risks

Media-heavy features must test:

- controller and stream disposal;
- cancellation during upload or navigation;
- duplicated submissions;
- stale progress from a previous upload session;
- permission denial and permanently denied states;
- invalid or missing URLs;
- local-file cleanup where implemented;
- track cleanup on disconnect and account/session transitions.

## Test boundary

Unit/widget tests must fake upload APIs and avoid pickers, codecs, cameras, microphones, LiveKit rooms, and platform channels. Integration tests may exercise platform behavior only in an explicitly configured environment.
