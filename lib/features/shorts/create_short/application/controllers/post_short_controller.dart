import 'dart:async';

import 'package:africaonlinestores/core/media/application/media_upload_coordinator.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_publishing_coordinator.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/short_local_media_saver.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/pending_short_publication.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

class PostShortController extends StateNotifier<UploadState> {
  PostShortController({
    required this.uploadApi,
    required this.managementApi,
    required this.mediaUploadCoordinator,
    required this.localMediaSaver,
    required this.publishingCoordinator,
    required this.sessionId,
    required this.ownerId,
  }) : super(UploadState.initial());

  final ShortsUploadApi uploadApi;
  final ShortsManagementApi managementApi;
  final MediaUploadCoordinator mediaUploadCoordinator;
  final ShortLocalMediaSaver localMediaSaver;
  final ShortPublishingCoordinator publishingCoordinator;
  final String sessionId;
  final String ownerId;

  bool _submitting = false;
  bool _disposed = false;
  CancelToken? _uploadCancelToken;
  PendingShortPublication? _pendingPublication;
  int _uploadOperationVersion = 1;

  void setMedia(List<SelectedMedia> media) {
    if (_disposed || state.isBusy) return;
    final previous = state.primaryMedia;
    final next = media.isEmpty ? null : media.first;
    if (previous != null &&
        next != null &&
        (previous.file.path != next.file.path ||
            previous.durationSeconds != next.durationSeconds)) {
      // A re-edit can reuse the same editor session but produce a different
      // logical file. The backend intentionally rejects reusing an init-upload
      // idempotency key with different file metadata.
      _uploadOperationVersion += 1;
    }
    state = state.copyWith(
      media: media,
      status: media.isEmpty ? UploadStatus.idle : UploadStatus.picked,
      clearError: true,
    );
  }

  void setAd(String? adId, {AOSAdListItem? preview}) {
    if (_disposed || state.isBusy) return;
    final clean = adId?.trim();
    final hasAd = clean != null && clean.isNotEmpty;
    final soundAllowed = !hasAd || state.selectedSound.isCommercialSafe;
    state = state.copyWith(
      selectedAdId: clean,
      selectedAdPreview: preview,
      clearSelectedAd: !hasAd,
      selectedSound: soundAllowed ? state.selectedSound : ShortSound.original,
      errorMessage: soundAllowed
          ? null
          : 'That sound cannot be used with a tagged product. Original audio was selected.',
      clearError: soundAllowed,
    );
  }

  void clearAd() {
    if (_disposed || state.isBusy) return;
    state = state.copyWith(clearSelectedAd: true, clearError: true);
  }

  void setAudience(String audience) {
    if (_disposed || state.isBusy) return;
    const supported = <String>{'everyone', 'followers', 'friends', 'only_me'};
    if (!supported.contains(audience)) return;
    state = state.copyWith(audience: audience);
  }

  void setAllowComments(bool value) {
    if (!_disposed && !state.isBusy) {
      state = state.copyWith(allowComments: value);
    }
  }

  void setAllowDownloads(bool value) {
    if (!_disposed && !state.isBusy) {
      state = state.copyWith(allowDownloads: value);
    }
  }

  void setSaveToDevice(bool value) {
    if (_disposed || state.isBusy) return;
    state = state.copyWith(
      saveToDevice: value,
      savedToDevice: value && state.savedToDevice,
    );
  }

  void setSound(ShortSound sound) {
    if (_disposed || state.isBusy) return;
    if (state.hasSelectedAd && !sound.isCommercialSafe) {
      state = state.copyWith(
        errorMessage: 'Choose a commercial-safe sound for a product Short.',
      );
      return;
    }
    state = state.copyWith(selectedSound: sound, clearError: true);
  }

  void setCaption(String caption) {
    if (!_disposed && !state.isBusy) state = state.copyWith(caption: caption);
  }

  void setHashtags(List<String> tags) {
    if (_disposed || state.isBusy) return;
    final seen = <String>{};
    final normalized = <String>[];
    for (final raw in tags) {
      final clean = raw.trim().replaceFirst(RegExp('^#+'), '').toLowerCase();
      if (clean.isEmpty || !seen.add(clean)) continue;
      normalized.add(clean);
      if (normalized.length == 10) break;
    }
    state = state.copyWith(hashtags: normalized);
  }

  Future<void> upload() async {
    if (_submitting || _disposed || !state.canUpload) return;
    final media = state.primaryMedia;
    if (media == null || media.type != MediaType.video) return;

    final durationSeconds = media.durationSeconds ?? 0;
    if (durationSeconds <= 0) {
      _fail('Video duration is unavailable. Reopen the video and try again.');
      return;
    }
    if (durationSeconds > 600) {
      _fail('Shorts can be up to 10 minutes long.');
      return;
    }

    final retryProgress = state.status == UploadStatus.failed
        ? state.progress.clamp(0.0, 1.0).toDouble()
        : 0.0;
    _submitting = true;
    _uploadCancelToken = CancelToken();
    state = state.copyWith(
      status: UploadStatus.initializing,
      progress: retryProgress,
      clearError: true,
    );

    try {
      final file = media.file;
      if (state.saveToDevice && !state.savedToDevice) {
        try {
          await localMediaSaver.saveVideo(file.path);
          if (_disposed) return;
          state = state.copyWith(savedToDevice: true);
        } on ShortGalleryAccessDenied {
          _fail(
            'Gallery access was denied. Allow photo access in device settings and retry.',
          );
          return;
        } catch (_) {
          _fail('The video could not be saved to your device. Please retry.');
          return;
        }
      }

      appLogger.i('Starting Short upload for session $sessionId.');
      final uploaded = await mediaUploadCoordinator.uploadFile(
        file: file,
        useCase: MediaUseCase.shortVideo,
        durationSeconds: durationSeconds,
        uploadMode: 'auto',
        idempotencyKey: 'short-raw:$sessionId:v$_uploadOperationVersion',
        cancelToken: _uploadCancelToken,
        onStage: (ManagedMediaUploadStage stage) {
          if (_disposed) return;
          state = state.copyWith(
            status: switch (stage) {
              ManagedMediaUploadStage.preparing => UploadStatus.initializing,
              ManagedMediaUploadStage.initializing => UploadStatus.initializing,
              ManagedMediaUploadStage.uploading => UploadStatus.uploading,
              ManagedMediaUploadStage.confirming => UploadStatus.confirming,
            },
          );
        },
        onSendProgress: (sent, total) {
          if (_disposed || total <= 0) return;
          state = state.copyWith(
            status: UploadStatus.uploading,
            progress: (sent / total).clamp(0, 1).toDouble(),
          );
        },
      );
      if (_disposed) return;
      if (_uploadCancelToken?.isCancelled ?? false) {
        _markCancelled();
        return;
      }
      final mediaId = uploaded.fold<String?>((failure) {
        appLogger.w(
          'Short upload failed during ${state.status.name}: '
          'type=${failure.type}, status=${failure.statusCode}, '
          'error=${failure.error ?? 'none'}.',
        );
        _fail(failure.message);
        return null;
      }, (result) => result.mediaId);
      if (mediaId == null) return;

      final created = await uploadApi.createShort(
        rawVideoMedia: mediaId,
        audience: state.audience,
        allowComments: state.allowComments,
        allowDownloads: state.allowDownloads,
        soundId: state.selectedSound.isOriginal ? null : state.selectedSound.id,
        soundStartMs: state.selectedSound.startMs,
        soundDurationMs: state.selectedSound.durationMs,
        soundVolume: state.selectedSound.volume,
      );
      if (_disposed) return;
      final shortId = created.fold<String?>((failure) {
        appLogger.w(
          'Short creation failed after media upload: '
          'type=${failure.type}, status=${failure.statusCode}, '
          'error=${failure.error ?? 'none'}.',
        );
        _fail(failure.message);
        return null;
      }, (value) => value);
      if (shortId == null) return;

      final job = PendingShortPublication(
        sessionId: sessionId,
        ownerId: ownerId,
        shortId: shortId,
        localMediaPath: media.file.path,
        contentMode: state.contentMode,
        adId: state.selectedAdId,
        caption: state.caption,
        hashtags: state.hashtags,
        audience: state.audience,
        allowComments: state.allowComments,
        allowDownloads: state.allowDownloads,
        sound: state.selectedSound,
        createdAt: DateTime.now().toUtc(),
      );
      _pendingPublication = job;
      state = state.copyWith(
        shortId: ShortId(shortId),
        status: UploadStatus.publishing,
        progress: 1,
        clearError: true,
      );
      await publishingCoordinator.enqueue(
        job,
        onProgress: _handlePublicationProgress(job),
      );
    } on DioException catch (error) {
      if (!_disposed) {
        if (CancelToken.isCancel(error)) {
          _markCancelled();
        } else {
          appLogger.w(
            'Short upload threw during ${state.status.name}: '
            'type=${error.type}, status=${error.response?.statusCode}.',
          );
          _fail('Upload interrupted. Retry will reuse confirmed upload work.');
        }
      }
    } catch (error) {
      if (!_disposed) {
        appLogger.w(
          'Short upload failed during ${state.status.name}: '
          '${error.runtimeType}.',
        );
        _fail('Upload failed. Please retry.');
      }
    } finally {
      _submitting = false;
      _uploadCancelToken = null;
    }
  }

  Future<void> _continuePublishing(PendingShortPublication job) async {
    await publishingCoordinator.start(
      job,
      onProgress: _handlePublicationProgress(job),
    );
  }

  void Function(PublicationProgress progress) _handlePublicationProgress(
    PendingShortPublication job,
  ) {
    return (PublicationProgress progress) {
      if (_disposed) return;
      switch (progress) {
        case PublicationProgress.processing:
          state = state.copyWith(
            status: UploadStatus.processing,
            shortId: ShortId(job.shortId),
            clearError: true,
          );
          return;
        case PublicationProgress.ready:
          state = state.copyWith(
            status: UploadStatus.ready,
            shortId: ShortId(job.shortId),
            clearError: true,
          );
          return;
        case PublicationProgress.failed:
          _fail('Your Short could not be finished. Retry when you are ready.');
          return;
        case PublicationProgress.timedOut:
          _fail(
            'Publishing is taking longer than expected. Retry to check again.',
          );
          return;
      }
    };
  }

  Future<void> retryProcessingCurrent() async {
    if (_submitting || _disposed) return;
    final job = _pendingPublication;
    final shortId = state.shortId?.value ?? job?.shortId;
    if (shortId == null || shortId.trim().isEmpty) return;

    _submitting = true;
    state = state.copyWith(status: UploadStatus.processing, clearError: true);
    try {
      final current = await managementApi.getShort(shortId: shortId);
      if (_disposed) return;
      final short = current.rightOrNull;
      if (short != null && short.isPlayable) {
        if (job != null) await _continuePublishing(job);
        return;
      }
      if (short == null || short.canRetry) {
        final retried = await managementApi.retryProcessing(shortId: shortId);
        if (retried.isLeft) {
          _fail(retried.leftOrNull!.message);
          return;
        }
      }
      if (job != null) {
        await _continuePublishing(job);
      } else {
        _fail('Publishing details are unavailable. Reopen the pending upload.');
      }
    } finally {
      _submitting = false;
    }
  }

  void cancelUpload() {
    if (state.shortId != null) return;
    if (state.status != UploadStatus.initializing &&
        state.status != UploadStatus.uploading) {
      return;
    }
    _uploadCancelToken?.cancel('Cancelled by user.');
  }

  void reset() {
    if (_disposed || state.isBusy) return;
    _pendingPublication = null;
    state = UploadState.initial();
  }

  void _markCancelled() {
    if (_disposed) return;
    _uploadOperationVersion += 1;
    state = state.copyWith(
      status: UploadStatus.failed,
      progress: 0,
      errorMessage: 'Upload cancelled.',
    );
  }

  void _fail(String message) {
    if (_disposed) return;
    state = state.copyWith(status: UploadStatus.failed, errorMessage: message);
  }

  @override
  void dispose() {
    _disposed = true;
    _uploadCancelToken?.cancel('Controller disposed.');
    super.dispose();
  }
}
