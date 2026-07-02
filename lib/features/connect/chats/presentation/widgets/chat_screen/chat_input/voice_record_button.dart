import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_overlay.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_provider.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceRecordButton extends ConsumerWidget {
  const VoiceRecordButton({
    super.key,
    required this.onRecorded,
    this.disabled = false,
    this.size = 44,
  });

  final Future<void> Function(String filePath) onRecorded;
  final bool disabled;
  final double size;

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

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

          onLongPressStart: disabled
              ? null
              : (_) async {
                  await HapticFeedback.mediumImpact();
                  await controller.startRecording();
                },

          onLongPressMoveUpdate: disabled
              ? null
              : (details) {
                  controller.updateDrag(details.offsetFromOrigin.dx);

                  if (details.offsetFromOrigin.dy < -80 &&
                      state.status == VoiceRecordStatus.recording) {
                    HapticFeedback.lightImpact();
                    controller.lockRecording();
                  }
                },

          onLongPressEnd: disabled
              ? null
              : (_) async {
                  final path = await controller.finishRecording();

                  if (path != null) {
                    await onRecorded(path);
                  }
                },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: state.isRecording ? colors.red : colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              state.isRecording
                  ? Icons.radio_button_checked_rounded
                  : Icons.mic_rounded,
              color: colors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
