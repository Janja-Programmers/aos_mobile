import 'dart:io';

import 'package:africaonlinestores/core/media/data/media_upload_api.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/value_objects/short_id.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

class PostShortController extends StateNotifier<UploadState> {
  final ShortsUploadApi uploadApi;
  final ShortsManagementApi managementApi;
  final MediaUploadApi mediaUploadApi;
  final String sessionId;

  PostShortController({
    required this.uploadApi,
    required this.managementApi,
    required this.mediaUploadApi,
    required this.sessionId,
  }) : super(UploadState.initial());

  final ImagePicker _picker = ImagePicker();

  void setMedia(List<SelectedMedia> media) {
    state = state.copyWith(media: media);
  }

  // ───────────── PICK VIDEO ─────────────

  Future<void> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    state = state.copyWith(
      media: [SelectedMedia(File(file.path), MediaType.video)],
      status: UploadStatus.picked,
    );
  }

  // ───────────── SETTERS ─────────────

  void setContentMode(String contentMode) {
    final requiresAd = ShortContentModes.requiresAd(contentMode);

    final soundAllowed = !requiresAd || state.selectedSound.isCommercialSafe;

    state = state.copyWith(
      contentMode: contentMode,
      clearSelectedAd: !requiresAd,
      selectedSound: soundAllowed ? state.selectedSound : ShortSound.original,
    );
  }

  void setAd(String? adId, {AOSAdListItem? preview}) {
    state = state.copyWith(selectedAdId: adId, selectedAdPreview: preview);
  }

  void setAudience(String audience) {
    state = state.copyWith(audience: audience);
  }

  void setAllowComments(bool value) {
    state = state.copyWith(allowComments: value);
  }

  void setAllowDownloads(bool value) {
    state = state.copyWith(allowDownloads: value);
  }

  void setSound(ShortSound sound) {
    state = state.copyWith(selectedSound: sound);
  }

  void clearAd() {
    state = state.copyWith(clearSelectedAd: true);
  }

  void setCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  void setHashtags(List<String> tags) {
    state = state.copyWith(hashtags: tags);
  }

  // ───────────── UPLOAD FLOW ─────────────

  Future<void> upload() async {
    if (!state.canUpload) return;

    final media = state.primaryMedia;
    if (media == null || media.type != MediaType.video) return;

    final file = media.file;
    final filename = file.path.split('/').last;

    appLogger.i(
      '🚀 UPLOAD START | file=$filename | contentMode=${state.contentMode}',
    );

    state = state.copyWith(
      status: UploadStatus.initializing,
      progress: 0,
      clearError: true,
    );

    final mediaId = await _uploadRawVideo(file);
    if (mediaId == null) return;

    final shortId = await _createShort(mediaId);
    if (shortId == null) return;

    state = state.copyWith(
      shortId: ShortId(shortId),
      status: UploadStatus.processing,
    );

    final ready = await _waitUntilReady(shortId);
    if (!ready && state.status != UploadStatus.processing) return;

    final finalShort = await _updateMetadataAndFetch(shortId);
    if (finalShort == null) return;

    state = state.copyWith(
      status: finalShort.isPlayable
          ? UploadStatus.ready
          : UploadStatus.processing,
      short: finalShort,
    );

    appLogger.i(
      finalShort.isPlayable
          ? '🎉 FINAL SHORT READY'
          : '⏳ SHORT CREATED; STILL PROCESSING',
    );
  }

  Future<String?> _uploadRawVideo(File file) async {
    state = state.copyWith(status: UploadStatus.uploading);

    final res = await mediaUploadApi.uploadMedia(
      file: file,
      purpose: MediaUploadPurpose.shortVideoRaw,
      onSendProgress: (sent, total) {
        if (total <= 0) return;

        state = state.copyWith(
          progress: sent / total,
          status: UploadStatus.uploading,
        );
      },
    );

    return res.fold(
      (failure) {
        state = state.copyWith(
          status: UploadStatus.failed,
          errorMessage: failure.message,
        );
        return null;
      },
      (uploaded) {
        state = state.copyWith(progress: 1, status: UploadStatus.confirming);
        return uploaded.mediaId;
      },
    );
  }

  Future<String?> _createShort(String mediaId) async {
    final res = await uploadApi.createShort(
      rawVideoMedia: mediaId,
      audience: state.audience,
      allowComments: state.allowComments,
      allowDownloads: state.allowDownloads,
    );

    return res.fold((failure) {
      state = state.copyWith(
        status: UploadStatus.failed,
        errorMessage: failure.message,
      );
      return null;
    }, (shortId) => shortId);
  }

  // ───────────── POLLING ─────────────

  Future<bool> _waitUntilReady(String shortId) async {
    const maxAttempts = 60;
    Short? latestShort;

    for (int i = 0; i < maxAttempts; i++) {
      final res = await managementApi.getShort(shortId: shortId);

      final done = res.fold((_) => false, (short) {
        latestShort = short;

        if (short.isPlayable) return true;

        if (short.canRetry) {
          state = state.copyWith(
            status: UploadStatus.failed,
            short: short,
            errorMessage: 'Video processing failed.',
          );
          return true;
        }

        return false;
      });

      if (state.status == UploadStatus.failed) return false;
      if (done) return true;

      await Future<void>.delayed(const Duration(seconds: 3));
    }

    final short = latestShort;

    if (short != null && !short.canRetry) {
      state = state.copyWith(
        status: short.isPlayable ? UploadStatus.ready : UploadStatus.processing,
        short: short,
        shortId: ShortId(shortId),
        clearError: true,
      );

      return short.isPlayable;
    }

    state = state.copyWith(
      status: UploadStatus.processing,
      shortId: ShortId(shortId),
      clearError: true,
    );

    return false;
  }

  // ───────────── FINAL FETCH ─────────────

  Future<Short?> _updateMetadataAndFetch(String shortId) async {
    final res = await uploadApi.updateMetadata(
      shortId: shortId,
      contentMode: state.contentMode,
      adId: state.requiresAd ? state.selectedAdId : null,
      caption: state.caption,
      hashtags: state.hashtags,
      audience: state.audience,
      allowComments: state.allowComments,
      allowDownloads: state.allowDownloads,
      soundId: state.selectedSound.isOriginal ? null : state.selectedSound.id,
      soundStartMs: state.selectedSound.startMs,
      soundDurationMs: state.selectedSound.durationMs,
      soundVolume: state.selectedSound.volume,
    );

    final metadataUpdated = res.fold((e) {
      state = state.copyWith(
        status: UploadStatus.failed,
        errorMessage: e.message,
      );
      return false;
    }, (_) => true);

    if (!metadataUpdated) return null;

    final shortRes = await managementApi.getShort(shortId: shortId);

    return shortRes.fold((e) {
      state = state.copyWith(
        status: UploadStatus.failed,
        errorMessage: e.message,
      );
      return null;
    }, (short) => short);
  }

  // ───────────── RETRY PROCESSING ─────────────

  Future<void> retryProcessingCurrent() async {
    final currentShortId = state.shortId?.value ?? state.short?.id.value;
    if (currentShortId == null || currentShortId.trim().isEmpty) return;

    state = state.copyWith(status: UploadStatus.processing, clearError: true);

    final currentRes = await managementApi.getShort(shortId: currentShortId);

    final handledCurrentState = currentRes.fold((_) => false, (short) {
      state = state.copyWith(short: short, shortId: ShortId(currentShortId));

      if (short.isPlayable) {
        state = state.copyWith(status: UploadStatus.ready, short: short);
        return true;
      }

      if (short.isProcessing && !short.canRetry) {
        return true;
      }

      return false;
    });

    if (handledCurrentState) {
      if (state.status == UploadStatus.ready) return;

      final ready = await _waitUntilReady(currentShortId);
      if (!ready && state.status != UploadStatus.processing) return;

      final finalShort = await _updateMetadataAndFetch(currentShortId);
      if (finalShort == null) return;

      state = state.copyWith(
        status: finalShort.isPlayable
            ? UploadStatus.ready
            : UploadStatus.processing,
        short: finalShort,
      );
      return;
    }

    final retryRes = await managementApi.retryProcessing(
      shortId: currentShortId,
    );

    final retryStarted = retryRes.fold((e) {
      state = state.copyWith(
        status: UploadStatus.failed,
        errorMessage: e.message,
      );
      return false;
    }, (_) => true);

    if (!retryStarted) return;

    final ready = await _waitUntilReady(currentShortId);
    if (!ready && state.status != UploadStatus.processing) return;

    final finalShort = await _updateMetadataAndFetch(currentShortId);
    if (finalShort == null) return;

    state = state.copyWith(
      status: finalShort.isPlayable
          ? UploadStatus.ready
          : UploadStatus.processing,
      short: finalShort,
    );
  }

  // ───────────── RESET ─────────────

  void reset() {
    state = UploadState.initial();
  }
}
