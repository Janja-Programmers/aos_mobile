import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_editor_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_mentions_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_recorder_controller.dart';
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
        cameraDriver: PluginShortCameraDriver(),
        videoPicker: ImagePickerShortVideoPicker(),
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

final shortMentionsControllerProvider =
    StateNotifierProvider.autoDispose<
      ShortMentionsController,
      ShortMentionsState
    >((ref) {
      return ShortMentionsController(ref.read(socialApiProvider));
    });
