import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/init_short_upload_result.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short.dart';

class PostShortController extends StateNotifier<UploadState> {
  final ShortsUploadApi uploadApi;
  final ShortsManagementApi managementApi;
  final String sessionId;

  PostShortController({
    required this.uploadApi,
    required this.managementApi,
    required this.sessionId,
  }) : super(UploadState.initial());

  void setMedia(List<SelectedMedia> media) {
    state = state.copyWith(media: media);
  }

  final ImagePicker _picker = ImagePicker();

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

  void setAd(String adId) {
    state = state.copyWith(selectedAdId: adId);
  }

  void setCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  void setHashtags(List<String> tags) {
    state = state.copyWith(hashtags: tags);
  }

  // ───────────── UPLOAD FLOW ─────────────

  Future<void> upload() async {
    if (state.selectedAdId == null) return;

    final media = state.primaryMedia;
    if (media == null || media.type != MediaType.video) return;

    final file = media.file;
    final filename = file.path.split('/').last;

    appLogger.i('🚀 UPLOAD START | file=$filename');

    state = state.copyWith(
      status: UploadStatus.initializing,
      short: null,
      progress: 0,
    );

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
    final res = await uploadApi.initUpload(filename: filename);

    return res.fold((e) {
      state = state.copyWith(status: UploadStatus.failed);
      return null;
    }, (r) => r);
  }

  // ───────────── UPLOAD FILE ─────────────

  Future<bool> _uploadFile(File file, String url) async {
    state = state.copyWith(status: UploadStatus.uploading);

    try {
      await Dio().put(
        url,
        data: file.openRead(),
        options: Options(headers: {'Content-Length': await file.length()}),
        onSendProgress: (sent, total) {
          if (total == 0) return;

          state = state.copyWith(
            progress: sent / total,
            status: UploadStatus.uploading,
          );
        },
      );

      return true;
    } catch (_) {
      state = state.copyWith(status: UploadStatus.failed);
      return false;
    }
  }

  // ───────────── CONFIRM ─────────────

  Future<bool> _confirmUpload(String shortId) async {
    state = state.copyWith(status: UploadStatus.confirming);

    final res = await uploadApi.confirmUpload(shortId: shortId);

    return res.fold(
      (e) {
        state = state.copyWith(status: UploadStatus.failed);
        return false;
      },
      (_) {
        state = state.copyWith(status: UploadStatus.processing);
        return true;
      },
    );
  }

  // ───────────── POLLING ─────────────

  Future<bool> _waitUntilReady(String shortId) async {
    const maxAttempts = 30;

    for (int i = 0; i < maxAttempts; i++) {
      final res = await managementApi.getShort(shortId: shortId);

      final done = res.fold((_) => false, (short) {
        if (short.isPlayable) return true;
        if (short.canRetry) {
          state = state.copyWith(status: UploadStatus.failed);
          return true;
        }
        return false;
      });

      if (done) return true;

      await Future.delayed(const Duration(seconds: 3));
    }

    state = state.copyWith(status: UploadStatus.failed);
    return false;
  }

  // ───────────── FINAL FETCH ─────────────

  Future<Short?> _updateMetadataAndFetch(String shortId) async {
    try {
      await uploadApi.updateMetadata(
        adId: state.selectedAdId!,
        shortId: shortId,
        caption: state.caption,
        hashtags: state.hashtags,
      );

      final res = await managementApi.getShort(shortId: shortId);

      return res.fold((_) => null, (short) => short);
    } catch (_) {
      state = state.copyWith(status: UploadStatus.failed);
      return null;
    }
  }

  // ───────────── RESET ─────────────

  void reset() {
    state = UploadState.initial();
  }
}
