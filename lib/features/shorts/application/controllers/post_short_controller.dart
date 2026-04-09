import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/data/models/init_short_upload_result.dart';
import 'package:africaonlinestores/features/shorts/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/data/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/domain/short.dart';

class PostShortController extends StateNotifier<UploadState> {
  final ShortsUploadApi uploadApi;
  final ShortsManagementApi managementApi;

  PostShortController({required this.uploadApi, required this.managementApi})
    : super(UploadState.initial());

  final ImagePicker _picker = ImagePicker();

  // ───────────── PICK VIDEO ─────────────

  Future<void> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    state = state.copyWith(
      videoFile: File(file.path),
      status: UploadStatus.picked,
    );
  }

  // ───────────── SETTERS ─────────────

  void setAd(String adId) {
    state = state.copyWith(selectedAdId: adId);
  }

  void setCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  void setHashtags(List<String> tags) {
    state = state.copyWith(hashtags: tags);
  }

  // ───────────── FULL UPLOAD FLOW ─────────────

  Future<void> upload() async {
    if (state.videoFile == null || state.selectedAdId == null) {
      appLogger.w('🚫 Upload aborted');
      return;
    }

    final file = state.videoFile!;
    final filename = file.path.split('/').last;

    appLogger.i('🚀 UPLOAD START | file=$filename');

    state = state.copyWith(status: UploadStatus.initializing);

    // 1. INIT
    final init = await _initUpload(filename);
    if (init == null) return;

    final shortId = init.shortId.value;

    // 2. UPLOAD
    if (!await _uploadFile(file, init.uploadUrl)) return;

    // 3. CONFIRM
    if (!await _confirmUpload(shortId)) return;

    // 4. WAIT (processing)
    if (!await _waitUntilReady(shortId)) return;

    // 5. METADATA + FINAL FETCH
    final finalShort = await _updateMetadataAndFetch(shortId);
    if (finalShort == null) return;

    // FINAL STATE
    state = state.copyWith(status: UploadStatus.ready, short: finalShort);

    appLogger.i('🎉 FINAL SHORT READY');
  }

  // ───────────── INIT ─────────────

  Future<InitShortUploadResult?> _initUpload(String filename) async {
    appLogger.i('🔹 INIT UPLOAD');

    final res = await uploadApi.initUpload(filename: filename);

    return res.fold(
      (e) {
        appLogger.e('❌ INIT FAILED', error: e);
        state = state.copyWith(status: UploadStatus.failed);
        return null;
      },
      (r) {
        appLogger.i('✅ INIT SUCCESS | shortId=${r.shortId}');
        return r;
      },
    );
  }

  // ───────────── FILE UPLOAD ─────────────

  Future<bool> _uploadFile(File file, String url) async {
    appLogger.i('🔹 UPLOAD FILE');

    state = state.copyWith(status: UploadStatus.uploading);

    try {
      await Dio().put(
        url,
        data: file.openRead(),
        options: Options(headers: {'Content-Length': await file.length()}),
        onSendProgress: (sent, total) {
          if (total == 0) return;

          final progress = sent / total;

          appLogger.i('📤 ${(progress * 100).toStringAsFixed(1)}%');

          state = state.copyWith(
            progress: progress,
            status: UploadStatus.uploading,
          );
        },
      );

      appLogger.i('✅ FILE UPLOAD COMPLETE');
      return true;
    } catch (e, st) {
      appLogger.e('❌ FILE UPLOAD FAILED', error: e, stackTrace: st);
      state = state.copyWith(status: UploadStatus.failed);
      return false;
    }
  }

  // ───────────── CONFIRM ─────────────

  Future<bool> _confirmUpload(String shortId) async {
    appLogger.i('🔹 CONFIRM UPLOAD');

    state = state.copyWith(status: UploadStatus.processing);

    final res = await uploadApi.confirmUpload(shortId: shortId);

    return res.fold(
      (e) {
        appLogger.e('❌ CONFIRM FAILED', error: e);
        state = state.copyWith(status: UploadStatus.failed);
        return false;
      },
      (_) {
        appLogger.i('✅ CONFIRM SUCCESS');
        return true;
      },
    );
  }

  // ───────────── POLLING ─────────────

  Future<bool> _waitUntilReady(String shortId) async {
    appLogger.i('🔹 WAIT UNTIL READY');

    const interval = Duration(seconds: 2);
    const maxAttempts = 30;

    for (int i = 0; i < maxAttempts; i++) {
      final res = await managementApi.getShort(shortId: shortId);

      final done = res.fold((_) => false, (short) {
        appLogger.i(
          '🔄 POLLING | status=${short.status} | ready=${short.isPlayable}',
        );

        if (short.isPlayable) {
          appLogger.i('✅ VIDEO READY');
          return true;
        }

        if (short.canRetry) {
          appLogger.w('⚠️ FAILED / RETRY');
          _updateToFailed(short);
          return true;
        }

        return false;
      });

      if (done) return true;

      await Future.delayed(interval);
    }

    appLogger.e('❌ PROCESSING TIMEOUT');
    state = state.copyWith(status: UploadStatus.failed);
    return false;
  }

  // ───────────── METADATA + FINAL FETCH ─────────────

  Future<Short?> _updateMetadataAndFetch(String shortId) async {
    appLogger.i('🔹 UPDATE METADATA');

    try {
      await uploadApi.updateMetadata(
        adId: state.selectedAdId!,
        shortId: shortId,
        caption: state.caption,
        hashtags: state.hashtags,
      );

      appLogger.i('✅ METADATA UPDATED');

      final res = await managementApi.getShort(shortId: shortId);

      return res.fold((_) => null, (short) => short);
    } catch (e, st) {
      appLogger.e('❌ METADATA FAILED', error: e, stackTrace: st);
      state = state.copyWith(status: UploadStatus.failed);
      return null;
    }
  }

  // ───────────── STATE HELPERS ─────────────

  void _updateToFailed(Short short) {
    state = state.copyWith(status: UploadStatus.failed, short: short);
  }

  // ───────────── RESET ─────────────

  void reset() {
    state = UploadState.initial();
  }
}
