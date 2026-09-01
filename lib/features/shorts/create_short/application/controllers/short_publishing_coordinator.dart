import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/features/shorts/create_short/data/pending_short_publication_repository.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/short_draft_repository.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/pending_short_publication.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_upload_api.dart';

class ShortPublishingCoordinator {
  ShortPublishingCoordinator({
    required ShortsUploadApi uploadApi,
    required ShortsManagementApi managementApi,
    required PendingShortPublicationRepository repository,
    required ShortDraftRepository draftRepository,
    void Function(String shortId)? onReady,
  }) : _uploadApi = uploadApi,
       _managementApi = managementApi,
       _repository = repository,
       _draftRepository = draftRepository,
       _onReady = onReady;

  final ShortsUploadApi _uploadApi;
  final ShortsManagementApi _managementApi;
  final PendingShortPublicationRepository _repository;
  final ShortDraftRepository _draftRepository;
  final void Function(String shortId)? _onReady;
  final Set<String> _activeSessions = <String>{};

  Future<void> enqueue(
    PendingShortPublication job, {
    void Function(PublicationProgress progress)? onProgress,
  }) async {
    await _repository.save(job);
    unawaited(_run(job, onProgress: onProgress));
  }

  Future<void> start(
    PendingShortPublication job, {
    void Function(PublicationProgress progress)? onProgress,
  }) async {
    await _repository.save(job);
    await _run(job, onProgress: onProgress);
  }

  Future<void> _run(
    PendingShortPublication job, {
    void Function(PublicationProgress progress)? onProgress,
  }) async {
    if (!_activeSessions.add(job.sessionId)) return;
    try {
      onProgress?.call(PublicationProgress.processing);
      const maxAttempts = 400;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final result = await _managementApi.getShort(shortId: job.shortId);
        final short = result.rightOrNull;
        if (short != null) {
          if (short.canRetry) {
            onProgress?.call(PublicationProgress.failed);
            return;
          }
          if (short.isPlayable) {
            final metadata = await _uploadApi.updateMetadata(
              shortId: job.shortId,
              adId: job.adId,
              includeAdId: job.adId?.trim().isNotEmpty ?? false,
              caption: job.caption,
              hashtags: job.hashtags,
              audience: job.audience,
              allowComments: job.allowComments,
              allowDownloads: job.allowDownloads,
            );
            if (metadata.isLeft) {
              onProgress?.call(PublicationProgress.failed);
              return;
            }
            await _repository.delete(job.sessionId);
            await _draftRepository.delete(job.sessionId);
            await _deleteLocalMedia(job.localMediaPath);
            _onReady?.call(job.shortId);
            onProgress?.call(PublicationProgress.ready);
            return;
          }
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
      onProgress?.call(PublicationProgress.timedOut);
    } catch (_) {
      onProgress?.call(PublicationProgress.failed);
    } finally {
      _activeSessions.remove(job.sessionId);
    }
  }

  Future<void> _deleteLocalMedia(String path) async {
    final clean = path.trim();
    if (clean.isEmpty) return;
    final file = File(clean);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> resumePending({required String ownerId}) async {
    final cleanOwner = ownerId.trim();
    if (cleanOwner.isEmpty) return;
    final jobs = await _repository.loadAll(ownerId: cleanOwner);
    for (final job in jobs) {
      unawaited(_run(job));
    }
  }
}

enum PublicationProgress { processing, ready, failed, timedOut }
