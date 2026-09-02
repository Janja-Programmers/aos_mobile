import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_editor_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_mentions_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_recorder_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/plugin_short_camera_driver.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/short_video_exporter.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:africaonlinestores/features/shorts/music/application/sound_picker_controller.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final shortVideoExporterProvider = Provider<ShortVideoExporter>((ref) {
  return ProShortVideoExporter();
});

final shortRecorderControllerProvider =
    StateNotifierProvider.autoDispose<
      ShortRecorderController,
      ShortRecorderState
    >((ref) {
      return ShortRecorderController(
        cameraDriver: PluginShortCameraDriver(
          cameraResources: ref.read(mediaCameraResourceCoordinatorProvider),
          staging: ref.read(mediaFileStagingServiceProvider),
        ),
        videoPicker: SharedShortVideoPicker(
          ref.read(mediaAcquisitionServiceProvider),
        ),
        permissionGate: const PluginShortPermissionGate(),
      );
    });

final shortEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<ShortEditorController, ShortEditorState, ShortEditorSeed>((
      ref,
      seed,
    ) {
      return ShortEditorController(
        seed: seed,
        draftRepository: ref.read(shortDraftRepositoryProvider),
        exporter: ref.read(shortVideoExporterProvider),
      );
    });

final soundPickerControllerProvider =
    StateNotifierProvider.autoDispose<SoundPickerController, SoundPickerState>((
      ref,
    ) {
      return SoundPickerController(ref.read(shortsSoundsApiProvider));
    });

/// Mention search is scoped to the active Short publishing session.
///
/// The publish screen watches this family member for its entire lifetime, so
/// the inline `@` suggestions and the mention modal share one controller while
/// still allowing Riverpod to dispose it when that publishing session leaves
/// the widget tree.
final shortMentionsControllerProvider = StateNotifierProvider.autoDispose
    .family<ShortMentionsController, ShortMentionsState, String>((ref, _) {
      return ShortMentionsController(ref.read(socialApiProvider));
    });
