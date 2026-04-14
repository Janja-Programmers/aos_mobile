import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/connect/voice/voice_record_controller.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_overlay.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';

class VoiceRecordButton extends ConsumerWidget {
  const VoiceRecordButton({
    super.key,
    required this.onRecorded,
    this.disabled = false,
  });

  final Future<void> Function(String filePath) onRecorded;
  final bool disabled;

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceRecordControllerProvider);
    final controller = ref.read(voiceRecordControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.isRecording)
          VoiceRecordOverlay(
            isCanceling: state.status == VoiceRecordStatus.canceling,
            isLocked: state.status == VoiceRecordStatus.locked,
            durationText: _formatDuration(state.duration),
          ),

        GestureDetector(
          behavior: HitTestBehavior.opaque,

          // -------------------------
          // START RECORDING
          // -------------------------
          onLongPressStart: disabled
              ? null
              : (_) async {
                  await HapticFeedback.mediumImpact();
                  await controller.startRecording();
                },

          // -------------------------
          // DRAG (cancel / lock)
          // -------------------------
          onLongPressMoveUpdate: disabled
              ? null
              : (details) {
                  controller.updateDrag(details.offsetFromOrigin.dx);

                  // 🔒 Lock (slide up)
                  if (details.offsetFromOrigin.dy < -80 &&
                      state.status == VoiceRecordStatus.recording) {
                    HapticFeedback.lightImpact();
                    controller.lockRecording();
                  }
                },

          // -------------------------
          // RELEASE
          // -------------------------
          onLongPressEnd: disabled
              ? null
              : (_) async {
                  final path = await controller.finishRecording();

                  if (path != null) {
                    await onRecorded(path);
                  }
                },

          child: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: Icon(
              state.isRecording ? Icons.radio_button_on : Icons.mic_none,
              color: disabled
                  ? Colors.grey
                  : state.isRecording
                  ? Colors.red
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
