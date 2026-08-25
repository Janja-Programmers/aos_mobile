// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:path_provider/path_provider.dart';

class MediaFileStagingService {
  int _sequence = 0;

  Future<void> prune({Duration maxAge = const Duration(days: 2)}) async {
    try {
      final temporary = await getTemporaryDirectory();
      final directory = Directory(
        '${temporary.path}${Platform.pathSeparator}aos_media_staging',
      );
      if (!await directory.exists()) return;

      final cutoff = DateTime.now().subtract(maxAge);
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! File) continue;
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoff)) await entity.delete();
      }
    } on Exception {
      // Staging cleanup is best effort and must never block media selection.
    }
  }

  Future<AcquiredMedia> stageFile({
    required File sourceFile,
    required MediaKind kind,
    required MediaAcquisitionSource source,
    String? originalName,
  }) async {
    if (!await sourceFile.exists()) {
      throw const MediaAcquisitionException('The selected file is missing.');
    }
    final sourceSize = await sourceFile.length();
    if (sourceSize <= 0) {
      throw const MediaAcquisitionException('The selected file is empty.');
    }

    final requestedName = originalName?.trim() ?? '';
    final name = requestedName.isNotEmpty
        ? requestedName
        : mediaFilename(sourceFile.path);
    final extension = mediaExtension(name);
    final outputPath = await reservePath(
      extension: extension.isEmpty ? 'bin' : extension,
      prefix: 'acquired',
    );
    final staged = await sourceFile.copy(outputPath);

    return AcquiredMedia(
      file: staged,
      kind: kind,
      source: source,
      originalName: name,
      ownedByApp: true,
    );
  }

  Future<String> reservePath({
    required String extension,
    required String prefix,
  }) async {
    final temporary = await getTemporaryDirectory();
    final directory = Directory(
      '${temporary.path}${Platform.pathSeparator}aos_media_staging',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _sequence += 1;
    final cleanExtension = extension.toLowerCase().replaceAll(
      RegExp('[^a-z0-9]'),
      '',
    );
    final suffix = cleanExtension.isEmpty ? 'bin' : cleanExtension;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${directory.path}${Platform.pathSeparator}'
        '${prefix}_${stamp}_$_sequence.$suffix';
  }
}
