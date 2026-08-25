import 'dart:async';

import 'package:africaonlinestores/core/media/application/media_acquisition_service.dart';
import 'package:africaonlinestores/core/media/application/media_camera_resource_coordinator.dart';
import 'package:africaonlinestores/core/media/application/media_file_staging_service.dart';
import 'package:africaonlinestores/core/media/application/media_preparation_service.dart';
import 'package:africaonlinestores/core/media/application/media_type_detector.dart';
import 'package:africaonlinestores/core/media/application/media_upload_coordinator.dart';
import 'package:africaonlinestores/core/media/data/adapters/camera_media_adapter.dart';
import 'package:africaonlinestores/core/media/data/adapters/file_picker_media_adapter.dart';
import 'package:africaonlinestores/core/media/data/adapters/image_picker_media_adapter.dart';
import 'package:africaonlinestores/core/media/data/adapters/native_image_preparation_adapter.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaFileStagingServiceProvider = Provider<MediaFileStagingService>((
  ref,
) {
  final staging = MediaFileStagingService();
  unawaited(staging.prune());
  return staging;
});

final mediaCameraResourceCoordinatorProvider =
    Provider<MediaCameraResourceCoordinator>((ref) {
      return MediaCameraResourceCoordinator();
    });

final imagePickerMediaAdapterProvider = Provider<ImagePickerMediaAdapter>((
  ref,
) {
  return ImagePickerMediaAdapter(
    staging: ref.read(mediaFileStagingServiceProvider),
  );
});

final filePickerMediaAdapterProvider = Provider<FilePickerMediaAdapter>((ref) {
  return FilePickerMediaAdapter(
    staging: ref.read(mediaFileStagingServiceProvider),
  );
});

final cameraMediaAdapterProvider = Provider<InAppCameraMediaAdapter>((ref) {
  return InAppCameraMediaAdapter(
    staging: ref.read(mediaFileStagingServiceProvider),
    cameraResources: ref.read(mediaCameraResourceCoordinatorProvider),
  );
});

final mediaAcquisitionServiceProvider = Provider<MediaAcquisitionService>((
  ref,
) {
  return MediaAcquisitionService(
    gallery: ref.read(imagePickerMediaAdapterProvider),
    files: ref.read(filePickerMediaAdapterProvider),
    camera: ref.read(cameraMediaAdapterProvider),
  );
});

final nativeImagePreparationAdapterProvider =
    Provider<NativeImagePreparationAdapter>((ref) {
      return const NativeImagePreparationAdapter();
    });

final mediaPreparationServiceProvider = Provider<MediaPreparationService>((
  ref,
) {
  return MediaPreparationService(
    staging: ref.read(mediaFileStagingServiceProvider),
    images: ref.read(nativeImagePreparationAdapterProvider),
    typeDetector: const MediaTypeDetector(),
  );
});

final mediaUploadCoordinatorProvider = Provider<MediaUploadCoordinator>((ref) {
  return MediaUploadCoordinator(
    uploadApi: ref.read(mediaUploadApiProvider),
    preparation: ref.read(mediaPreparationServiceProvider),
  );
});
