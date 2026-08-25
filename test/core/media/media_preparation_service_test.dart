// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/application/media_preparation_service.dart';
import 'package:africaonlinestores/core/media/application/media_type_detector.dart';
import 'package:africaonlinestores/core/media/data/adapters/native_image_preparation_adapter.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'prepared images use bounded JPEG output owned by preparation',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'media-preparation-success',
      );
      addTearDown(() => directory.delete(recursive: true));
      final source = File('${directory.path}/source.jpg');
      await source.writeAsBytes(<int>[0xFF, 0xD8, 0xFF, 0xE0]);
      final staging = _TestStagingService(directory);
      final service = MediaPreparationService(
        staging: staging,
        images: const _CopyingImageAdapter(),
        typeDetector: const MediaTypeDetector(),
      );

      final prepared = await service.prepare(
        media: AcquiredMedia.external(file: source, kind: MediaKind.image),
        useCase: MediaUseCase.profileImage,
      );

      expect(prepared.kind, MediaKind.image);
      expect(prepared.contentType, 'image/jpeg');
      expect(prepared.ownedByPreparation, isTrue);
      expect(await prepared.file.exists(), isTrue);

      await prepared.discard();
      expect(await prepared.file.exists(), isFalse);
      expect(await source.exists(), isTrue);
    },
  );

  test('oversized prepared output is rejected and removed', () async {
    const mb = 1024 * 1024;
    final directory = await Directory.systemTemp.createTemp(
      'media-preparation-limit',
    );
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/source.jpg');
    final handle = await source.open(mode: FileMode.write);
    try {
      await handle.writeFrom(<int>[0xFF, 0xD8, 0xFF, 0xE0]);
      await handle.truncate(6 * mb);
    } finally {
      await handle.close();
    }
    final staging = _TestStagingService(directory);
    final service = MediaPreparationService(
      staging: staging,
      images: const _CopyingImageAdapter(),
      typeDetector: const MediaTypeDetector(),
    );

    await expectLater(
      service.prepare(
        media: AcquiredMedia.external(file: source, kind: MediaKind.image),
        useCase: MediaUseCase.profileImage,
      ),
      throwsA(isA<MediaPolicyException>()),
    );

    expect(staging.lastPath, isNotNull);
    expect(await File(staging.lastPath!).exists(), isFalse);
  });
}

final class _TestStagingService extends MediaFileStagingService {
  _TestStagingService(this.directory);

  final Directory directory;
  String? lastPath;
  int _sequence = 0;

  @override
  Future<String> reservePath({
    required String extension,
    required String prefix,
  }) async {
    _sequence += 1;
    lastPath = '${directory.path}/$prefix-$_sequence.$extension';
    return lastPath!;
  }
}

final class _CopyingImageAdapter extends NativeImagePreparationAdapter {
  const _CopyingImageAdapter();

  @override
  Future<File?> compressToJpeg({
    required File source,
    required String destinationPath,
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    return source.copy(destinationPath);
  }
}
