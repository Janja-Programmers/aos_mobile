import 'dart:io';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/application/media_preparation_service.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_result.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:dio/dio.dart';

enum ManagedMediaUploadStage { preparing, initializing, uploading, confirming }

class MediaBatchUploadFailure {
  const MediaBatchUploadFailure({
    required this.index,
    required this.media,
    required this.failure,
  });

  final int index;
  final AcquiredMedia media;
  final Failure failure;
}

class MediaBatchUploadResult {
  const MediaBatchUploadResult({required this.uploads, required this.failures});

  final List<MediaUploadResult> uploads;
  final List<MediaBatchUploadFailure> failures;

  bool get isSuccess => failures.isEmpty;
}

class MediaUploadCoordinator {
  const MediaUploadCoordinator({
    required MediaUploadApi uploadApi,
    required MediaPreparationService preparation,
  }) : _uploadApi = uploadApi,
       _preparation = preparation;

  final MediaUploadApi _uploadApi;
  final MediaPreparationService _preparation;

  Future<Either<Failure, MediaUploadResult>> upload({
    required AcquiredMedia media,
    required MediaUseCase useCase,
    double? durationSeconds,
    String? uploadMode,
    String? idempotencyKey,
    CancelToken? cancelToken,
    bool discardSourceWhenDone = false,
    void Function(ManagedMediaUploadStage stage)? onStage,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    PreparedMedia? prepared;
    try {
      final purpose = MediaPolicies.forUseCase(useCase).uploadPurpose;
      if (purpose == null || purpose.isEmpty) {
        return Either.left(
          const Failure('This media is not configured for upload.'),
        );
      }
      onStage?.call(ManagedMediaUploadStage.preparing);
      prepared = await _preparation.prepare(media: media, useCase: useCase);

      final result = await _uploadApi.uploadMedia(
        file: prepared.file,
        purpose: purpose,
        contentType: prepared.contentType,
        durationSeconds: durationSeconds,
        uploadMode: uploadMode,
        idempotencyKey: idempotencyKey,
        cancelToken: cancelToken,
        onStage: (stage) {
          onStage?.call(switch (stage) {
            MediaUploadStage.initializing =>
              ManagedMediaUploadStage.initializing,
            MediaUploadStage.uploading => ManagedMediaUploadStage.uploading,
            MediaUploadStage.confirming => ManagedMediaUploadStage.confirming,
          });
        },
        onSendProgress: onSendProgress,
      );
      if (result.isRight && discardSourceWhenDone) await media.discard();
      return result;
    } on MediaPolicyException catch (error) {
      return Either.left(Failure(error.message));
    } on FileSystemException {
      return Either.left(const Failure('Could not read selected media.'));
    } on Object {
      return Either.left(const Failure('Could not prepare selected media.'));
    } finally {
      await prepared?.discard();
    }
  }

  Future<Either<Failure, MediaUploadResult>> uploadFile({
    required File file,
    required MediaUseCase useCase,
    double? durationSeconds,
    String? uploadMode,
    String? idempotencyKey,
    CancelToken? cancelToken,
    void Function(ManagedMediaUploadStage stage)? onStage,
    void Function(int sent, int total)? onSendProgress,
  }) {
    final policy = MediaPolicies.forUseCase(useCase);
    final extension = mediaExtension(file.path);
    final kind = _kindForExternalFile(policy, extension);
    return upload(
      media: AcquiredMedia.external(file: file, kind: kind),
      useCase: useCase,
      durationSeconds: durationSeconds,
      uploadMode: uploadMode,
      idempotencyKey: idempotencyKey,
      cancelToken: cancelToken,
      onStage: onStage,
      onSendProgress: onSendProgress,
    );
  }

  Future<MediaBatchUploadResult> uploadBatch({
    required List<AcquiredMedia> media,
    required MediaUseCase useCase,
    int maxConcurrent = 2,
    bool discardSourcesOnSuccess = true,
  }) async {
    if (media.isEmpty) {
      return const MediaBatchUploadResult(
        uploads: <MediaUploadResult>[],
        failures: <MediaBatchUploadFailure>[],
      );
    }

    final policy = MediaPolicies.forUseCase(useCase);
    if (media.length > policy.maxItems) {
      final failure = Failure(
        'This action accepts at most ${policy.maxItems} media items.',
      );
      return MediaBatchUploadResult(
        uploads: const <MediaUploadResult>[],
        failures: <MediaBatchUploadFailure>[
          for (var index = policy.maxItems; index < media.length; index += 1)
            MediaBatchUploadFailure(
              index: index,
              media: media[index],
              failure: failure,
            ),
        ],
      );
    }

    final results = List<Either<Failure, MediaUploadResult>?>.filled(
      media.length,
      null,
    );
    var cursor = 0;

    Future<void> worker() async {
      while (cursor < media.length) {
        final index = cursor;
        cursor += 1;
        results[index] = await upload(media: media[index], useCase: useCase);
      }
    }

    final workerCount = maxConcurrent
        .clamp(1, 4)
        .clamp(1, media.length)
        .toInt();
    await Future.wait<void>(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );

    final uploads = <MediaUploadResult>[];
    final failures = <MediaBatchUploadFailure>[];
    for (var index = 0; index < results.length; index += 1) {
      final result = results[index];
      if (result == null) {
        failures.add(
          MediaBatchUploadFailure(
            index: index,
            media: media[index],
            failure: const Failure('Media upload did not complete.'),
          ),
        );
        continue;
      }
      result.fold(
        (failure) => failures.add(
          MediaBatchUploadFailure(
            index: index,
            media: media[index],
            failure: failure,
          ),
        ),
        uploads.add,
      );
    }

    if (failures.isNotEmpty) {
      for (final upload in uploads) {
        await _uploadApi.deleteMedia(mediaId: upload.mediaId);
      }
      return MediaBatchUploadResult(
        uploads: const <MediaUploadResult>[],
        failures: failures,
      );
    }

    if (discardSourcesOnSuccess) {
      for (final source in media) {
        await source.discard();
      }
    }
    return MediaBatchUploadResult(uploads: uploads, failures: failures);
  }

  MediaKind _kindForExternalFile(MediaPolicy policy, String extension) {
    if (policy.allowedKinds.length == 1) return policy.allowedKinds.first;
    const imageExtensions = <String>{
      'jpg',
      'jpeg',
      'png',
      'webp',
      'heic',
      'heif',
    };
    if (imageExtensions.contains(extension)) return MediaKind.image;
    return policy.allowedKinds.first;
  }
}
