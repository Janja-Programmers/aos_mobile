import 'dart:async';

import 'package:africaonlinestores/core/media/data/media_upload_api.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_publishing_coordinator.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/short_local_media_saver.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/pending_short_publication.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

class PostShortController extends StateNotifier<UploadState> {
  PostShortController({
    required this.uploadApi,
    required this.managementApi,
    required this.mediaUploadApi,
    required this.localMediaSaver,
    required this.publishingCoordinator,
    required this.sessionId,
    required this.ownerId,
  }) : super(UploadState.initial());

  final ShortsUploadApi uploadApi;
  final ShortsManagementApi managementApi;
  final MediaUploadApi mediaUploadApi;
  final ShortLocalMediaSaver localMediaSaver;
  final ShortPublishingCoordinator publishingCoordinator;
  final String sessionId;
  final String ownerId;

  bool _submitting = false;
  bool _disposed = false;
  CancelToken? _uploadCancelToken;
  PendingShortPublication? _pendingPublication;

  void setMedia(List<SelectedMedia> media) {
    if (_disposed || state.isBusy) return;
    state = state.copyWith(
      media: media,
      status: media.isEmpty ? UploadStatus.idle : UploadStatus.picked,
      clearError: true,
    );
  }

  void setContentMode(String contentMode) {
    if (_disposed || state.isBusy) return;
    final normalized = ShortContentModes.normalize(contentMode);
    final requiresAd = ShortContentModes.requiresAd(normalized);
    final soundAllowed = !requiresAd || state.selectedSound.isCommercialSafe;
    state = state.copyWith(
      contentMode: normalized,
      clearSelectedAd: !requiresAd,
      selectedSound: soundAllowed ? state.selectedSound : ShortSound.original,
      errorMessage: soundAllowed
          ? null
          : 'That sound cannot be used with Shop content. Original audio was selected.',
      clearError: soundAllowed,
    );
  }

  void setAd(String? adId, {AOSAdListItem? preview}) {
    if (_disposed || state.isBusy) return;
    final clean = adId?.trim();
    state = state.copyWith(
      selectedAdId: clean,
      selectedAdPreview: preview,
      clearSelectedAd: clean == null || clean.isEmpty,
    );
  }

  void clearAd() {
    if (_disposed || state.isBusy) return;
    state = state.copyWith(clearSelectedAd: true);
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
    if (state.requiresAd && !sound.isCommercialSafe) {
      state = state.copyWith(
        errorMessage: 'Choose a commercial-safe sound for Shop content.',
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

    _submitting = true;
    _uploadCancelToken = CancelToken();
    state = state.copyWith(
      status: UploadStatus.initializing,
      progress: 0,
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
      final uploaded = await mediaUploadApi.uploadMedia(
        file: file,
        purpose: MediaUploadPurpose.shortVideoRaw,
        idempotencyKey: 'short-raw:$sessionId:v1',
        cancelToken: _uploadCancelToken,
        onStage: (MediaUploadStage stage) {
          if (_disposed) return;
          state = state.copyWith(
            status: switch (stage) {
              MediaUploadStage.initializing => UploadStatus.initializing,
              MediaUploadStage.uploading => UploadStatus.uploading,
              MediaUploadStage.confirming => UploadStatus.confirming,
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
      final mediaId = uploaded.fold<String?>((failure) {
        _fail(failure.message);
        return null;
      }, (result) => result.mediaId);
      if (mediaId == null) return;

      final created = await uploadApi.createShort(
        rawVideoMedia: mediaId,
        audience: state.audience,
        allowComments: state.allowComments,
        allowDownloads: state.allowDownloads,
      );
      if (_disposed) return;
      final shortId = created.fold<String?>((failure) {
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
        adId: state.requiresAd ? state.selectedAdId : null,
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
        _fail(
          CancelToken.isCancel(error)
              ? 'Upload cancelled.'
              : 'Upload failed. Please retry.',
        );
      }
    } catch (_) {
      if (!_disposed) _fail('Upload failed. Please retry.');
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
          _fail('Video processing failed. Retry when you are ready.');
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
    _uploadCancelToken?.cancel('Cancelled by user.');
  }

  void reset() {
    if (_disposed || state.isBusy) return;
    _pendingPublication = null;
    state = UploadState.initial();
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
