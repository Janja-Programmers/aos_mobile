import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:flutter/widgets.dart';

enum MediaFileSelectionType { any, document, audio, media, video }

enum MediaCaptureMode { photo, video }

abstract interface class GalleryMediaAdapter {
  Future<List<AcquiredMedia>> pickImages({
    required MediaUseCase useCase,
    required bool multiple,
    required int maxItems,
  });

  Future<AcquiredMedia?> pickVideo({required MediaUseCase useCase});
}

abstract interface class FileMediaAdapter {
  Future<List<AcquiredMedia>> pickFiles({
    required MediaUseCase useCase,
    required MediaKind kind,
    required MediaFileSelectionType selectionType,
    required bool multiple,
    required int maxItems,
  });
}

abstract interface class CameraMediaAdapter {
  Future<AcquiredMedia?> capture({
    required BuildContext context,
    required MediaUseCase useCase,
    required MediaCaptureMode mode,
    required MediaCameraFacing facing,
    Duration? maxDuration,
  });
}
