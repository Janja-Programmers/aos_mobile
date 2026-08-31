// ignore_for_file: unused_element_parameter, avoid_slow_async_io

import 'dart:convert';
import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/application/media_picker_operation_coordinator.dart';
import 'package:africaonlinestores/core/media/data/adapters/image_picker_gateway.dart';
import 'package:africaonlinestores/core/media/data/adapters/image_picker_media_adapter.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory directory;
  late _TestStagingService staging;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    directory = await Directory.systemTemp.createTemp('image-picker-adapter');
    staging = _TestStagingService(directory);
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test(
    'single gallery selection is immediately staged into app storage',
    () async {
      final source = await _writeImage(directory, 'provider.jpg');
      final gateway = _FakeImagePickerGateway(
        singleImage: PickerGatewayFile(path: source.path, name: 'provider.jpg'),
      );
      final adapter = ImagePickerMediaAdapter(
        staging: staging,
        gateway: gateway,
        pickerOperations: MediaPickerOperationCoordinator(),
      );

      final selected = await adapter.pickImages(
        useCase: MediaUseCase.profileImage,
        multiple: false,
        maxItems: 1,
      );

      expect(selected, hasLength(1));
      expect(selected.single.source, MediaAcquisitionSource.gallery);
      expect(selected.single.ownedByApp, isTrue);
      expect(selected.single.path, isNot(source.path));
      expect(await selected.single.file.exists(), isTrue);
      expect(gateway.singleImageCalls, 1);
      expect(gateway.retrieveLostDataCalls, 1);
    },
  );

  test('gallery cancellation clears the pending recovery journal', () async {
    final adapter = ImagePickerMediaAdapter(
      staging: staging,
      gateway: _FakeImagePickerGateway(),
      pickerOperations: MediaPickerOperationCoordinator(),
    );

    final selected = await adapter.pickImages(
      useCase: MediaUseCase.profileImage,
      multiple: false,
      maxItems: 1,
    );
    final preferences = await SharedPreferences.getInstance();

    expect(selected, isEmpty);
    expect(preferences.getString('media.image_picker.pending.v2'), isNull);
  });

  test('startup recovery is returned before opening a new picker', () async {
    final source = await _writeImage(directory, 'lost.jpg');
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'media.image_picker.pending.v2': jsonEncode(<String, Object?>{
        'id': 'pending-profile-image',
        'use_case': MediaUseCase.profileImage.name,
        'kind': MediaKind.image.name,
        'max_items': 1,
        'started_at_ms': now.millisecondsSinceEpoch,
      }),
    });
    final gateway = _FakeImagePickerGateway(
      lostData: PickerGatewayLostData(
        files: <PickerGatewayFile>[
          PickerGatewayFile(path: source.path, name: 'lost.jpg'),
        ],
      ),
    );
    final adapter = ImagePickerMediaAdapter(
      staging: staging,
      gateway: gateway,
      pickerOperations: MediaPickerOperationCoordinator(),
    );

    await adapter.initialize();
    final selected = await adapter.pickImages(
      useCase: MediaUseCase.profileImage,
      multiple: false,
      maxItems: 1,
    );

    expect(selected, hasLength(1));
    expect(selected.single.originalName, 'lost.jpg');
    expect(selected.single.path, isNot(source.path));
    expect(gateway.retrieveLostDataCalls, 1);
    expect(gateway.singleImageCalls, 0);
  });

  test(
    'recovered staged media survives another process-style adapter restart',
    () async {
      final source = await _writeImage(directory, 'lost_again.jpg');
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'media.image_picker.pending.v2': jsonEncode(<String, Object?>{
          'id': 'pending-review-image',
          'use_case': MediaUseCase.reviewImage.name,
          'kind': MediaKind.image.name,
          'max_items': 1,
          'started_at_ms': now.millisecondsSinceEpoch,
        }),
      });
      final firstGateway = _FakeImagePickerGateway(
        lostData: PickerGatewayLostData(
          files: <PickerGatewayFile>[
            PickerGatewayFile(path: source.path, name: 'lost_again.jpg'),
          ],
        ),
      );
      final first = ImagePickerMediaAdapter(
        staging: staging,
        gateway: firstGateway,
        pickerOperations: MediaPickerOperationCoordinator(),
      );
      await first.initialize();

      final secondGateway = _FakeImagePickerGateway();
      final second = ImagePickerMediaAdapter(
        staging: staging,
        gateway: secondGateway,
        pickerOperations: MediaPickerOperationCoordinator(),
      );
      await second.initialize();
      final selected = await second.pickImages(
        useCase: MediaUseCase.reviewImage,
        multiple: false,
        maxItems: 1,
      );

      expect(selected, hasLength(1));
      expect(selected.single.originalName, 'lost_again.jpg');
      expect(secondGateway.singleImageCalls, 0);
    },
  );

  test(
    'invalid persisted recovery metadata cannot bypass media policy',
    () async {
      final source = await _writeImage(directory, 'tampered.jpg');
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'media.image_picker.pending.v2': jsonEncode(<String, Object?>{
          'id': 'tampered-profile-video',
          'use_case': MediaUseCase.profileImage.name,
          'kind': MediaKind.video.name,
          'max_items': 99,
          'started_at_ms': now.millisecondsSinceEpoch,
        }),
      });
      final gateway = _FakeImagePickerGateway(
        lostData: PickerGatewayLostData(
          files: <PickerGatewayFile>[
            PickerGatewayFile(path: source.path, name: 'tampered.jpg'),
          ],
        ),
      );
      final adapter = ImagePickerMediaAdapter(
        staging: staging,
        gateway: gateway,
        pickerOperations: MediaPickerOperationCoordinator(),
      );

      await adapter.initialize();
      final selected = await adapter.pickImages(
        useCase: MediaUseCase.profileImage,
        multiple: false,
        maxItems: 1,
      );

      expect(selected, isEmpty);
      expect(gateway.singleImageCalls, 1);
    },
  );

  test('a second external picker cannot overlap an active picker', () async {
    final operations = MediaPickerOperationCoordinator();
    final active = operations.acquire(MediaPickerOwner.fileBrowser);
    addTearDown(active.release);
    final adapter = ImagePickerMediaAdapter(
      staging: staging,
      gateway: _FakeImagePickerGateway(),
      pickerOperations: operations,
    );

    await expectLater(
      adapter.pickImages(
        useCase: MediaUseCase.profileImage,
        multiple: false,
        maxItems: 1,
      ),
      throwsA(isA<MediaAcquisitionException>()),
    );
  });
}

Future<File> _writeImage(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes(<int>[0xFF, 0xD8, 0xFF, 0xD9]);
  return file;
}

final class _TestStagingService extends MediaFileStagingService {
  _TestStagingService(this.directory);

  final Directory directory;
  int sequence = 0;

  @override
  Future<AcquiredMedia> stageFile({
    required File sourceFile,
    required MediaKind kind,
    required MediaAcquisitionSource source,
    String? originalName,
  }) async {
    sequence += 1;
    final hasOriginalName = originalName?.trim().isNotEmpty ?? false;
    final name = hasOriginalName
        ? originalName!.trim()
        : mediaFilename(sourceFile.path);
    final extension = mediaExtension(name);
    final output = File(
      '${directory.path}/staged_$sequence.${extension.isEmpty ? 'bin' : extension}',
    );
    await sourceFile.copy(output.path);
    return AcquiredMedia(
      file: output,
      kind: kind,
      source: source,
      originalName: name,
      ownedByApp: true,
    );
  }
}

final class _FakeImagePickerGateway implements ImagePickerGateway {
  _FakeImagePickerGateway({
    this.singleImage,
    this.multipleImages = const <PickerGatewayFile>[],
    this.singleVideo,
    this.lostData = const PickerGatewayLostData(),
  });

  final PickerGatewayFile? singleImage;
  final List<PickerGatewayFile> multipleImages;
  final PickerGatewayFile? singleVideo;
  final PickerGatewayLostData lostData;

  int singleImageCalls = 0;
  int multipleImageCalls = 0;
  int singleVideoCalls = 0;
  int retrieveLostDataCalls = 0;

  @override
  Future<PickerGatewayFile?> pickSingleImage() async {
    singleImageCalls += 1;
    return singleImage;
  }

  @override
  Future<List<PickerGatewayFile>> pickMultipleImages({
    required int limit,
  }) async {
    multipleImageCalls += 1;
    return multipleImages.take(limit).toList(growable: false);
  }

  @override
  Future<PickerGatewayFile?> pickSingleVideo() async {
    singleVideoCalls += 1;
    return singleVideo;
  }

  @override
  Future<PickerGatewayLostData> retrieveLostData() async {
    retrieveLostDataCalls += 1;
    return lostData;
  }
}
