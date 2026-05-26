import 'package:africaonlinestores/features/connect/voice/audio_recorder_service.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_controller.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';
import 'package:africaonlinestores/features/connect/voice/voice_sound_feedback_service.dart';
import 'package:flutter_riverpod/legacy.dart';

final voiceRecordControllerProvider =
    StateNotifierProvider.autoDispose<VoiceRecordController, VoiceRecordState>((
      ref,
    ) {
      return VoiceRecordController(
        AudioRecorderService(),
        VoiceSoundFeedbackService(),
      );
    });
