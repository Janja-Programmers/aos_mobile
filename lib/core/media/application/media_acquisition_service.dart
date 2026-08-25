// ignore_for_file: avoid_slow_async_io

import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:flutter/widgets.dart';

class MediaAcquisitionService {
  const MediaAcquisitionService({
    required GalleryMediaAdapter gallery,
    required FileMediaAdapter files,
    required CameraMediaAdapter camera,
  }) : _gallery = gallery,
       _files = files,
       _camera = camera;

  final GalleryMediaAdapter _gallery;
  final FileMediaAdapter _files;
  final CameraMediaAdapter _camera;

  Future<AcquiredMedia?> captureImage(
    BuildContext context, {
    required MediaUseCase useCase,
    MediaCameraFacing? facing,
  }) async {
    final policy = MediaPolicies.forUseCase(useCase);
    final media = await _camera.capture(
      context: context,
      useCase: useCase,
      mode: MediaCaptureMode.photo,
      facing: facing ?? policy.preferredCamera,
    );
    return _validateOne(media, policy);
  }

  Future<AcquiredMedia?> captureVideo(
    BuildContext context, {
    required MediaUseCase useCase,
  }) async {
    final policy = MediaPolicies.forUseCase(useCase);
    final media = await _camera.capture(
      context: context,
      useCase: useCase,
      mode: MediaCaptureMode.video,
      facing: policy.preferredCamera,
      maxDuration: policy.maxCaptureDuration,
    );
    return _validateOne(media, policy);
  }

  Future<AcquiredMedia?> pickImage({required MediaUseCase useCase}) async {
    final selected = await pickImages(useCase: useCase, maxItems: 1);
    return selected.isEmpty ? null : selected.first;
  }

  Future<List<AcquiredMedia>> pickImages({
    required MediaUseCase useCase,
    int? maxItems,
  }) async {
    final policy = MediaPolicies.forUseCase(useCase);
    final boundedMax = (maxItems ?? policy.maxItems)
        .clamp(1, policy.maxItems)
        .toInt();
    final selected = await _gallery.pickImages(
      useCase: useCase,
      multiple: boundedMax > 1,
      maxItems: boundedMax,
    );
    return _validateMany(selected, policy, boundedMax);
  }

  Future<AcquiredMedia?> pickVideo({required MediaUseCase useCase}) async {
    final policy = MediaPolicies.forUseCase(useCase);
    final media = await _gallery.pickVideo(useCase: useCase);
    return _validateOne(media, policy);
  }

  Future<AcquiredMedia?> pickDocument({required MediaUseCase useCase}) async {
    return _pickSingleFile(
      useCase: useCase,
      kind: MediaKind.document,
      selectionType: MediaFileSelectionType.document,
    );
  }

  Future<AcquiredMedia?> pickAudio({required MediaUseCase useCase}) async {
    return _pickSingleFile(
      useCase: useCase,
      kind: MediaKind.audio,
      selectionType: MediaFileSelectionType.audio,
    );
  }

  Future<AcquiredMedia?> pickAnyFile({required MediaUseCase useCase}) async {
    return _pickSingleFile(
      useCase: useCase,
      kind: MediaKind.file,
      selectionType: MediaFileSelectionType.any,
    );
  }

  Future<AcquiredMedia?> pickMediaFile({required MediaUseCase useCase}) async {
    return _pickSingleFile(
      useCase: useCase,
      kind: MediaKind.file,
      selectionType: MediaFileSelectionType.media,
    );
  }

  Future<AcquiredMedia?> _pickSingleFile({
    required MediaUseCase useCase,
    required MediaKind kind,
    required MediaFileSelectionType selectionType,
  }) async {
    final policy = MediaPolicies.forUseCase(useCase);
    final selected = await _files.pickFiles(
      useCase: useCase,
      kind: kind,
      selectionType: selectionType,
      multiple: false,
      maxItems: 1,
    );
    if (selected.isEmpty) return null;
    return _validateOne(selected.first, policy);
  }

  Future<List<AcquiredMedia>> _validateMany(
    List<AcquiredMedia> selected,
    MediaPolicy policy,
    int maxItems,
  ) async {
    final accepted = <AcquiredMedia>[];
    try {
      for (final media in selected.take(maxItems)) {
        final valid = await _validateOne(media, policy);
        if (valid != null) accepted.add(valid);
      }
      for (final extra in selected.skip(maxItems)) {
        await extra.discard();
      }
      return accepted;
    } on Object {
      for (final media in selected) {
        await media.discard();
      }
      rethrow;
    }
  }

  Future<AcquiredMedia?> _validateOne(
    AcquiredMedia? media,
    MediaPolicy policy,
  ) async {
    if (media == null) return null;
    final file = media.file;
    if (!await file.exists()) {
      await media.discard();
      throw const MediaPolicyException(
        'The selected file is empty or missing.',
      );
    }
    final fileSize = await file.length();
    if (fileSize <= 0) {
      await media.discard();
      throw const MediaPolicyException(
        'The selected file is empty or missing.',
      );
    }
    if (!policy.allowedKinds.contains(media.kind)) {
      await media.discard();
      throw const MediaPolicyException(
        'This media type is not supported here.',
      );
    }
    final extension = mediaExtension(media.originalName);
    if (!policy.allowsExtension(extension)) {
      await media.discard();
      throw const MediaPolicyException('This file format is not supported.');
    }
    final maxBytes = media.kind == MediaKind.image
        ? policy.maxSourceBytes ?? policy.maxBytes
        : policy.maxBytes;
    if (maxBytes != null && fileSize > maxBytes) {
      await media.discard();
      throw MediaPolicyException(
        'The selected file exceeds the ${maxBytes ~/ (1024 * 1024)} MB limit.',
      );
    }
    return media;
  }
}
