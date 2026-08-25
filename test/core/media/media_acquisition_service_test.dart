// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/media/application/media_acquisition_service.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'selection is capped by policy and extra staged files are discarded',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'media-acquisition-cap',
      );
      addTearDown(() => directory.delete(recursive: true));
      final selected = <AcquiredMedia>[];
      for (var index = 0; index < 6; index += 1) {
        final file = File('${directory.path}/image_$index.jpg');
        await file.writeAsBytes(<int>[0xFF, 0xD8, 0xFF, index]);
        selected.add(
          AcquiredMedia(
            file: file,
            kind: MediaKind.image,
            source: MediaAcquisitionSource.gallery,
            originalName: mediaFilename(file.path),
            ownedByApp: true,
          ),
        );
      }
      final service = MediaAcquisitionService(
        gallery: _FakeGalleryAdapter(selected),
        files: const _EmptyFileAdapter(),
        camera: const _EmptyCameraAdapter(),
      );

      final result = await service.pickImages(
        useCase: MediaUseCase.reviewImage,
        maxItems: 99,
      );

      expect(result, hasLength(5));
      expect(await selected.last.file.exists(), isFalse);
    },
  );

  test(
    'a staged file with a disallowed extension is rejected and removed',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'media-acquisition-extension',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/not-an-image.txt');
      await file.writeAsString('not an image');
      final media = AcquiredMedia(
        file: file,
        kind: MediaKind.image,
        source: MediaAcquisitionSource.gallery,
        originalName: mediaFilename(file.path),
        ownedByApp: true,
      );
      final service = MediaAcquisitionService(
        gallery: _FakeGalleryAdapter(<AcquiredMedia>[media]),
        files: const _EmptyFileAdapter(),
        camera: const _EmptyCameraAdapter(),
      );

      await expectLater(
        service.pickImage(useCase: MediaUseCase.profileImage),
        throwsA(isA<MediaPolicyException>()),
      );
      expect(await file.exists(), isFalse);
    },
  );
}

final class _FakeGalleryAdapter implements GalleryMediaAdapter {
  const _FakeGalleryAdapter(this.selected);

  final List<AcquiredMedia> selected;

  @override
  Future<List<AcquiredMedia>> pickImages({
    required MediaUseCase useCase,
    required bool multiple,
    required int maxItems,
  }) async {
    return selected;
  }

  @override
  Future<AcquiredMedia?> pickVideo({required MediaUseCase useCase}) async {
    return null;
  }
}

final class _EmptyFileAdapter implements FileMediaAdapter {
  const _EmptyFileAdapter();

  @override
  Future<List<AcquiredMedia>> pickFiles({
    required MediaUseCase useCase,
    required MediaKind kind,
    required MediaFileSelectionType selectionType,
    required bool multiple,
    required int maxItems,
  }) async {
    return const <AcquiredMedia>[];
  }
}

final class _EmptyCameraAdapter implements CameraMediaAdapter {
  const _EmptyCameraAdapter();

  @override
  Future<AcquiredMedia?> capture({
    required BuildContext context,
    required MediaUseCase useCase,
    required MediaCaptureMode mode,
    required MediaCameraFacing facing,
    Duration? maxDuration,
  }) async {
    return null;
  }
}
