import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';

enum MediaUseCase {
  adImage,
  adVideo,
  searchImage,
  reviewImage,
  profileImage,
  liveCover,
  verificationDocument,
  verificationSelfie,
  sellerBanner,
  chatImage,
  chatVideo,
  chatDocument,
  chatAudio,
  chatFile,
  chatWallpaper,
  shortVideo,
  soundUpload,
}

class MediaPolicy {
  const MediaPolicy({
    required this.useCase,
    required this.allowedKinds,
    required this.allowedExtensions,
    required this.maxItems,
    this.uploadPurpose,
    this.maxBytes,
    this.maxSourceBytes,
    this.imageMaxWidth,
    this.imageMaxHeight,
    this.imageQuality = 85,
    this.preferredCamera = MediaCameraFacing.rear,
    this.maxCaptureDuration,
  });

  final MediaUseCase useCase;
  final Set<MediaKind> allowedKinds;
  final Set<String> allowedExtensions;
  final int maxItems;
  final String? uploadPurpose;
  final int? maxBytes;
  final int? maxSourceBytes;
  final int? imageMaxWidth;
  final int? imageMaxHeight;
  final int imageQuality;
  final MediaCameraFacing preferredCamera;
  final Duration? maxCaptureDuration;

  bool get preparesImage =>
      allowedKinds.contains(MediaKind.image) &&
      imageMaxWidth != null &&
      imageMaxHeight != null;

  bool allowsExtension(String extension) {
    return allowedExtensions.isEmpty ||
        allowedExtensions.contains(extension.toLowerCase());
  }
}

class MediaPolicies {
  const MediaPolicies._();

  static const int _megabyte = 1024 * 1024;
  static const Set<String> _images = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
  };
  static const Set<String> _videos = <String>{'mp4', 'm4v', 'mov'};
  static const Set<String> _audio = <String>{'mp3', 'm4a', 'aac', 'wav', 'ogg'};

  static MediaPolicy forUseCase(MediaUseCase useCase) {
    return switch (useCase) {
      MediaUseCase.adImage => const MediaPolicy(
        useCase: MediaUseCase.adImage,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 4,
        maxBytes: 10 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        uploadPurpose: MediaUploadPurpose.adImage,
        imageMaxWidth: 2560,
        imageMaxHeight: 2560,
      ),
      MediaUseCase.adVideo => const MediaPolicy(
        useCase: MediaUseCase.adVideo,
        allowedKinds: <MediaKind>{MediaKind.video},
        allowedExtensions: _videos,
        maxItems: 1,
        maxBytes: 200 * _megabyte,
        uploadPurpose: MediaUploadPurpose.adVideo,
        maxCaptureDuration: Duration(minutes: 5),
      ),
      MediaUseCase.searchImage => const MediaPolicy(
        useCase: MediaUseCase.searchImage,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 1,
        maxBytes: 15 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        imageMaxWidth: 1600,
        imageMaxHeight: 1600,
      ),
      MediaUseCase.reviewImage => const MediaPolicy(
        useCase: MediaUseCase.reviewImage,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 5,
        maxBytes: 10 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        uploadPurpose: MediaUploadPurpose.reviewImage,
        imageMaxWidth: 2048,
        imageMaxHeight: 2048,
      ),
      MediaUseCase.profileImage => const MediaPolicy(
        useCase: MediaUseCase.profileImage,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 1,
        maxBytes: 5 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        uploadPurpose: MediaUploadPurpose.profileImage,
        imageMaxWidth: 1600,
        imageMaxHeight: 1600,
        imageQuality: 88,
      ),
      MediaUseCase.liveCover => const MediaPolicy(
        useCase: MediaUseCase.liveCover,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 1,
        maxBytes: 10 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        uploadPurpose: MediaUploadPurpose.liveCover,
        imageMaxWidth: 1920,
        imageMaxHeight: 1920,
      ),
      MediaUseCase.verificationDocument => const MediaPolicy(
        useCase: MediaUseCase.verificationDocument,
        allowedKinds: <MediaKind>{MediaKind.image, MediaKind.document},
        allowedExtensions: <String>{..._images, 'pdf'},
        maxItems: 1,
        maxBytes: 20 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        uploadPurpose: MediaUploadPurpose.verificationDocument,
        imageMaxWidth: 2400,
        imageMaxHeight: 2400,
        imageQuality: 92,
      ),
      MediaUseCase.verificationSelfie => const MediaPolicy(
        useCase: MediaUseCase.verificationSelfie,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 1,
        maxBytes: 20 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        uploadPurpose: MediaUploadPurpose.verificationDocument,
        imageMaxWidth: 1920,
        imageMaxHeight: 1920,
        imageQuality: 90,
        preferredCamera: MediaCameraFacing.front,
      ),
      MediaUseCase.sellerBanner => const MediaPolicy(
        useCase: MediaUseCase.sellerBanner,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 1,
        maxBytes: 10 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        uploadPurpose: MediaUploadPurpose.sellerBanner,
        imageMaxWidth: 2560,
        imageMaxHeight: 1440,
      ),
      MediaUseCase.chatImage => const MediaPolicy(
        useCase: MediaUseCase.chatImage,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 10,
        maxBytes: 50 * _megabyte,
        maxSourceBytes: 50 * _megabyte,
        uploadPurpose: MediaUploadPurpose.chatAttachment,
        imageMaxWidth: 2048,
        imageMaxHeight: 2048,
      ),
      MediaUseCase.chatVideo => const MediaPolicy(
        useCase: MediaUseCase.chatVideo,
        allowedKinds: <MediaKind>{MediaKind.video},
        allowedExtensions: _videos,
        maxItems: 1,
        maxBytes: 50 * _megabyte,
        uploadPurpose: MediaUploadPurpose.chatAttachment,
        maxCaptureDuration: Duration(minutes: 5),
      ),
      MediaUseCase.chatDocument => const MediaPolicy(
        useCase: MediaUseCase.chatDocument,
        allowedKinds: <MediaKind>{MediaKind.document},
        allowedExtensions: <String>{'pdf'},
        maxItems: 1,
        maxBytes: 50 * _megabyte,
        uploadPurpose: MediaUploadPurpose.chatAttachment,
      ),
      MediaUseCase.chatAudio => const MediaPolicy(
        useCase: MediaUseCase.chatAudio,
        allowedKinds: <MediaKind>{MediaKind.audio},
        allowedExtensions: _audio,
        maxItems: 1,
        maxBytes: 50 * _megabyte,
        uploadPurpose: MediaUploadPurpose.chatAttachment,
      ),
      MediaUseCase.chatFile => const MediaPolicy(
        useCase: MediaUseCase.chatFile,
        allowedKinds: <MediaKind>{MediaKind.document, MediaKind.file},
        allowedExtensions: <String>{..._images, ..._videos, ..._audio, 'pdf'},
        maxItems: 1,
        maxBytes: 50 * _megabyte,
        uploadPurpose: MediaUploadPurpose.chatAttachment,
      ),
      MediaUseCase.chatWallpaper => const MediaPolicy(
        useCase: MediaUseCase.chatWallpaper,
        allowedKinds: <MediaKind>{MediaKind.image},
        allowedExtensions: _images,
        maxItems: 1,
        maxBytes: 15 * _megabyte,
        maxSourceBytes: 25 * _megabyte,
        imageMaxWidth: 1920,
        imageMaxHeight: 1920,
        imageQuality: 88,
      ),
      MediaUseCase.shortVideo => const MediaPolicy(
        useCase: MediaUseCase.shortVideo,
        allowedKinds: <MediaKind>{MediaKind.video},
        allowedExtensions: _videos,
        maxItems: 1,
        maxBytes: 300 * _megabyte,
        uploadPurpose: MediaUploadPurpose.shortVideoRaw,
        maxCaptureDuration: Duration(minutes: 10),
      ),
      MediaUseCase.soundUpload => const MediaPolicy(
        useCase: MediaUseCase.soundUpload,
        allowedKinds: <MediaKind>{MediaKind.audio},
        allowedExtensions: _audio,
        maxItems: 1,
        maxBytes: 50 * _megabyte,
        uploadPurpose: MediaUploadPurpose.soundUpload,
      ),
    };
  }
}
