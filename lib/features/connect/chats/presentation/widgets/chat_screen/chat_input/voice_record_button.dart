import 'dart:async';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_overlay.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_provider.dart';
import 'package:africaonlinestores/features/connect/voice/voice_record_state.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceRecordButton extends ConsumerStatefulWidget {
  const VoiceRecordButton({
    super.key,
    required this.onRecorded,
    this.disabled = false,
    this.size = 44,
  });

  final Future<void> Function(String filePath) onRecorded;
  final bool disabled;
  final double size;

  @override
  ConsumerState<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends ConsumerState<VoiceRecordButton> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onInactive: _cancelForLifecycle,
      onPause: _cancelForLifecycle,
      onDetach: _cancelForLifecycle,
    );
  }

  void _cancelForLifecycle() {
    final state = ref.read(voiceRecordControllerProvider);
    if (!state.isRecording) return;
    unawaited(
      ref.read(voiceRecordControllerProvider.notifier).cancelRecording(),
    );
  }

  String _formatDuration(Duration duration) {
    final mm = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(voiceRecordControllerProvider);
    final controller = ref.read(voiceRecordControllerProvider.notifier);

    ref.listen<VoiceRecordError?>(
      voiceRecordControllerProvider.select((value) => value.error),
      (previous, next) {
        if (next == null || next == previous || !mounted) return;
        ShowSnack(context, _voiceErrorMessage(l10n, next)).error();
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.isRecording)
          VoiceRecordOverlay(
            isCanceling: state.status == VoiceRecordStatus.canceling,
            isLocked: state.status == VoiceRecordStatus.locked,
            durationText: _formatDuration(state.duration),
          ),
        Semantics(
          button: true,
          enabled: !widget.disabled,
          label: state.isRecording
              ? l10n.chat_voice_release_to_finish
              : l10n.chat_voice_hold_to_record,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPressStart: widget.disabled
                ? null
                : (_) async {
                    await HapticFeedback.mediumImpact();
                    if (!mounted) return;
                    await controller.startRecording();
                  },
            onLongPressMoveUpdate: widget.disabled
                ? null
                : (details) {
                    controller.updateDrag(details.offsetFromOrigin.dx);
                    if (details.offsetFromOrigin.dy < -80 &&
                        state.status == VoiceRecordStatus.recording) {
                      unawaited(HapticFeedback.lightImpact());
                      controller.lockRecording();
                    }
                  },
            onLongPressEnd: widget.disabled
                ? null
                : (_) async {
                    final path = await controller.finishRecording();
                    if (!mounted || path == null) return;
                    await widget.onRecorded(path);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: state.isRecording ? colors.red : colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isRecording
                    ? Icons.stop_rounded
                    : Icons.mic_rounded,
                color: colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _voiceErrorMessage(
    AppLocalizations l10n,
    VoiceRecordError error,
  ) {
    return switch (error) {
      VoiceRecordError.microphonePermissionDenied =>
        l10n.chat_microphone_permission_denied,
      VoiceRecordError.startFailed => l10n.chat_voice_record_start_failed,
      VoiceRecordError.finishFailed => l10n.chat_voice_record_finish_failed,
    };
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }
}
