import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImagePickerMediaAdapter implements GalleryMediaAdapter {
  ImagePickerMediaAdapter({
    required MediaFileStagingService staging,
    ImagePicker? picker,
  }) : _staging = staging,
       _picker = picker ?? ImagePicker();

  static const String _pendingUseCaseKey =
      'media.pending_image_picker_use_case';

  final MediaFileStagingService _staging;
  final ImagePicker _picker;

  @override
  Future<List<AcquiredMedia>> pickImages({
    required MediaUseCase useCase,
    required bool multiple,
    required int maxItems,
  }) async {
    final recovered = await _recover(
      useCase: useCase,
      kind: MediaKind.image,
      maxItems: maxItems,
    );
    if (recovered.isNotEmpty) return recovered;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingUseCaseKey, useCase.name);
    try {
      final selected = <XFile>[];
      if (multiple) {
        selected.addAll(await _picker.pickMultiImage());
      } else {
        final file = await _picker.pickImage(source: ImageSource.gallery);
        if (file != null) selected.add(file);
      }
      return _stage(
        selected.take(maxItems),
        kind: MediaKind.image,
        source: MediaAcquisitionSource.gallery,
      );
    } on Exception catch (error) {
      throw MediaAcquisitionException(
        'The gallery could not be opened: $error',
      );
    } finally {
      await preferences.remove(_pendingUseCaseKey);
    }
  }

  @override
  Future<AcquiredMedia?> pickVideo({required MediaUseCase useCase}) async {
    final recovered = await _recover(
      useCase: useCase,
      kind: MediaKind.video,
      maxItems: 1,
    );
    if (recovered.isNotEmpty) return recovered.first;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingUseCaseKey, useCase.name);
    try {
      final selected = await _picker.pickVideo(source: ImageSource.gallery);
      if (selected == null) return null;
      final staged = await _stage(
        <XFile>[selected],
        kind: MediaKind.video,
        source: MediaAcquisitionSource.gallery,
      );
      return staged.first;
    } on Exception catch (error) {
      throw MediaAcquisitionException(
        'The video library could not be opened: $error',
      );
    } finally {
      await preferences.remove(_pendingUseCaseKey);
    }
  }

  Future<List<AcquiredMedia>> _recover({
    required MediaUseCase useCase,
    required MediaKind kind,
    required int maxItems,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_pendingUseCaseKey) != useCase.name) {
      return const <AcquiredMedia>[];
    }

    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return const <AcquiredMedia>[];
    if (response.exception != null) {
      await preferences.remove(_pendingUseCaseKey);
      throw const MediaAcquisitionException(
        'The interrupted media selection could not be recovered.',
      );
    }

    final files = response.files;
    if (files == null || files.isEmpty) return const <AcquiredMedia>[];
    await preferences.remove(_pendingUseCaseKey);
    return _stage(
      files.take(maxItems),
      kind: kind,
      source: MediaAcquisitionSource.gallery,
    );
  }

  Future<List<AcquiredMedia>> _stage(
    Iterable<XFile> files, {
    required MediaKind kind,
    required MediaAcquisitionSource source,
  }) async {
    final staged = <AcquiredMedia>[];
    try {
      for (final file in files) {
        staged.add(
          await _staging.stageFile(
            sourceFile: File(file.path),
            kind: kind,
            source: source,
            originalName: file.name,
          ),
        );
      }
      return staged;
    } on Object {
      for (final media in staged) {
        await media.discard();
      }
      rethrow;
    }
  }
}
