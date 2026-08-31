import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_acquisition_ports.dart';
import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/application/media_picker_operation_coordinator.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerMediaAdapter implements FileMediaAdapter {
  FilePickerMediaAdapter({
    required MediaFileStagingService staging,
    required MediaPickerOperationCoordinator pickerOperations,
  }) : _staging = staging,
       _pickerOperations = pickerOperations;

  final MediaFileStagingService _staging;
  final MediaPickerOperationCoordinator _pickerOperations;

  @override
  Future<List<AcquiredMedia>> pickFiles({
    required MediaUseCase useCase,
    required MediaKind kind,
    required MediaFileSelectionType selectionType,
    required bool multiple,
    required int maxItems,
  }) async {
    final policy = MediaPolicies.forUseCase(useCase);
    final fileType = switch (selectionType) {
      MediaFileSelectionType.any =>
        policy.allowedExtensions.isEmpty ? FileType.any : FileType.custom,
      MediaFileSelectionType.document => FileType.custom,
      MediaFileSelectionType.audio => FileType.audio,
      MediaFileSelectionType.media => FileType.media,
      MediaFileSelectionType.video => FileType.video,
    };

    final lease = _acquirePickerLease();

    try {
      final result = await FilePicker.pickFiles(
        type: fileType,
        allowMultiple: multiple,
        allowedExtensions: fileType == FileType.custom
            ? policy.allowedExtensions.toList(growable: false)
            : null,
      );
      if (result == null || result.files.isEmpty) {
        return const <AcquiredMedia>[];
      }

      final staged = <AcquiredMedia>[];
      try {
        for (final selected in result.files.take(maxItems)) {
          final path = selected.path;
          if (path == null || path.trim().isEmpty) continue;
          staged.add(
            await _staging.stageFile(
              sourceFile: File(path),
              kind: kind,
              source: MediaAcquisitionSource.fileSystem,
              originalName: selected.name,
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
    } on MediaAcquisitionException {
      rethrow;
    } on Exception catch (error) {
      throw MediaAcquisitionException(
        'The file browser could not be opened: $error',
      );
    } finally {
      lease.release();
    }
  }

  MediaPickerLease _acquirePickerLease() {
    try {
      return _pickerOperations.acquire(MediaPickerOwner.fileBrowser);
    } on MediaPickerBusyException {
      throw const MediaAcquisitionException(
        'Another media selection is already in progress.',
      );
    }
  }
}
