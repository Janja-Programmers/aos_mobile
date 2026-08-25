// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/application/media_type_detector.dart';
import 'package:africaonlinestores/core/media/data/adapters/native_image_preparation_adapter.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';

class MediaPreparationService {
  const MediaPreparationService({
    required MediaFileStagingService staging,
    required NativeImagePreparationAdapter images,
    required MediaTypeDetector typeDetector,
  }) : _staging = staging,
       _images = images,
       _typeDetector = typeDetector;

  final MediaFileStagingService _staging;
  final NativeImagePreparationAdapter _images;
  final MediaTypeDetector _typeDetector;

  Future<PreparedMedia> prepare({
    required AcquiredMedia media,
    required MediaUseCase useCase,
  }) async {
    final policy = MediaPolicies.forUseCase(useCase);
    final source = media.file;
    if (!await source.exists()) {
      throw const MediaPolicyException(
        'The selected file is empty or missing.',
      );
    }
    final sourceSize = await source.length();
    if (sourceSize <= 0) {
      throw const MediaPolicyException(
        'The selected file is empty or missing.',
      );
    }

    final extension = mediaExtension(media.originalName);
    if (!policy.allowsExtension(extension)) {
      throw const MediaPolicyException('This file format is not supported.');
    }

    final detected = await _typeDetector.detect(source);
    final effectiveKind = detected.kind == MediaKind.file
        ? media.kind
        : detected.kind;
    if (!policy.allowedKinds.contains(effectiveKind)) {
      throw const MediaPolicyException(
        'The selected file content does not match the required media type.',
      );
    }

    if (effectiveKind == MediaKind.image && policy.preparesImage) {
      final maxSourceBytes = policy.maxSourceBytes;
      if (maxSourceBytes != null && sourceSize > maxSourceBytes) {
        throw MediaPolicyException(
          'The selected image exceeds the '
          '${maxSourceBytes ~/ (1024 * 1024)} MB source limit.',
        );
      }
      final destination = await _staging.reservePath(
        extension: 'jpg',
        prefix: 'prepared',
      );
      try {
        final prepared = await _images.compressToJpeg(
          source: source,
          destinationPath: destination,
          maxWidth: policy.imageMaxWidth!,
          maxHeight: policy.imageMaxHeight!,
          quality: policy.imageQuality,
        );
        if (prepared == null ||
            !await prepared.exists() ||
            await prepared.length() <= 0) {
          throw const MediaPolicyException(
            'The image could not be prepared safely.',
          );
        }
        final preparedSize = await prepared.length();
        _validateSize(preparedSize, policy);
        return PreparedMedia(
          file: prepared,
          kind: MediaKind.image,
          contentType: 'image/jpeg',
          sizeBytes: preparedSize,
          ownedByPreparation: true,
        );
      } on Object {
        final failedOutput = File(destination);
        if (await failedOutput.exists()) await failedOutput.delete();
        rethrow;
      }
    }

    _validateSize(sourceSize, policy);
    return PreparedMedia(
      file: source,
      kind: effectiveKind,
      contentType: detected.contentType,
      sizeBytes: sourceSize,
      ownedByPreparation: false,
    );
  }

  void _validateSize(int sizeBytes, MediaPolicy policy) {
    final maxBytes = policy.maxBytes;
    if (maxBytes == null || sizeBytes <= maxBytes) return;
    throw MediaPolicyException(
      'The prepared file exceeds the ${maxBytes ~/ (1024 * 1024)} MB limit.',
    );
  }
}
