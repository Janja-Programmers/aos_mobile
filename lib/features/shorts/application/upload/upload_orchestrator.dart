import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_upload_request.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/caption.dart';
import 'package:africaonlinestores/features/shorts/domain/repository/shorts_repository.dart';

import 'package:africaonlinestores/features/shorts/application/upload/processing_watcher.dart';
import 'package:africaonlinestores/features/shorts/application/upload/upload_state.dart';

class UploadOrchestrator extends StateNotifier<UploadState> {
  final ShortsRepository _repository;
  final Dio _dio;
  final ProcessingWatcher _watcher;

  UploadOrchestrator({
    required ShortsRepository repository,
    required Dio dio,
    required ProcessingWatcher watcher,
  }) : _repository = repository,
       _dio = dio,
       _watcher = watcher,
       super(UploadState.initial());

  Future<void> uploadShort({
    required String adId,
    required String filePath,
    String? caption,
    List<String>? hashtags,
  }) async {
    try {
      final filename = filePath.split(Platform.pathSeparator).last;

      // 🔹 INITIAL STATE
      state = UploadState.initial().copyWith(
        stage: UploadStage.initializing,
        progress: 0,
        clearError: true,
        clearShort: true,
      );

      // 🔹 BUILD REQUEST
      final request = ShortUploadRequest(
        filePath: filePath,
        caption: caption,
        hashtags: hashtags,
        filename: filename,
      );

      // 🔹 INIT UPLOAD
      final init = await _repository.initUpload(request: request);

      state = state.copyWith(
        stage: UploadStage.uploading,
        shortId: init.shortId,
        progress: 0,
      );

      // 🔹 UPLOAD FILE TO PRESIGNED URL
      await _uploadFileToPresignedUrl(
        filePath: filePath,
        uploadUrl: init.uploadUrl,
      );

      // 🔹 CONFIRM UPLOAD
      state = state.copyWith(stage: UploadStage.confirming, progress: 0.7);

      await _repository.confirmUpload(shortId: init.shortId);

      state = state.copyWith(stage: UploadStage.processing);

      // 🔥 WAIT for backend processing
      await _watcher.waitUntilReady(init.shortId);

      // 🔹 UPDATE METADATA (FINAL STEP → MAKES PLAYABLE)
      final hasCaption = caption != null && caption.trim().isNotEmpty;
      final hasHashtags = hashtags != null && hashtags.isNotEmpty;

      // ✅ NOW safe to update metadata
      await _repository.updateMetadata(
        adId: adId,
        shortId: init.shortId,
        caption: hasCaption ? Caption(caption.trim()) : null,
        hashtags: hasHashtags ? hashtags : null,
      );

      // 🔹 FINAL STATE
      state = state.copyWith(stage: UploadStage.ready, progress: 1);
    } catch (e) {
      state = state.copyWith(
        stage: UploadStage.failed,
        errorMessage: e.toString(),
      );

      return;
    }
  }

  Future<Short?> retryProcessing() async {
    final shortId = state.shortId;
    if (shortId == null) return null;

    try {
      state = state.copyWith(stage: UploadStage.processing, clearError: true);

      await _repository.retryProcessing(shortId: shortId);

      final result = await _watcher.waitUntilReady(shortId);

      if (result.isPlayable) {
        state = state.copyWith(stage: UploadStage.ready, short: result);
        return result;
      }

      state = state.copyWith(
        stage: UploadStage.failed,
        short: result,
        errorMessage: 'Retry completed but short is still not ready.',
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        stage: UploadStage.failed,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = UploadState.initial();
  }

  Future<void> _uploadFileToPresignedUrl({
    required String filePath,
    required String uploadUrl,
  }) async {
    final file = File(filePath);
    final length = await file.length();

    await _dio.put(
      uploadUrl,
      data: file.openRead(),
      options: Options(headers: {Headers.contentLengthHeader: length}),
      onSendProgress: (sent, total) {
        final progress = total > 0 ? sent / total : 0.0;

        state = state.copyWith(
          stage: UploadStage.uploading,
          progress: progress,
        );
      },
    );
  }
}
