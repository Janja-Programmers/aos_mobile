import 'dart:math' as math;

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class VoiceRecordOverlay extends StatelessWidget {
  const VoiceRecordOverlay({
    super.key,
    required this.durationText,
    required this.amplitudes,
    required this.isPaused,
    required this.isSending,
    required this.onDelete,
    required this.onTogglePause,
    required this.onSend,
  });

  final String durationText;
  final List<double> amplitudes;
  final bool isPaused;
  final bool isSending;
  final VoidCallback onDelete;
  final VoidCallback onTogglePause;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final pauseLabel = isPaused
        ? l10n.chat_voice_resume
        : l10n.chat_voice_pause;

    return Semantics(
      liveRegion: true,
      container: true,
      label: l10n.chat_voice_recording_status(durationText, pauseLabel),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.elevated,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 42,
                child: Row(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48),
                      child: Text(
                        durationText,
                        maxLines: 1,
                        style: context.pStrong.copyWith(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _VoiceWaveformPainter(
                            amplitudes: amplitudes,
                            waveformColor: isPaused
                                ? colors.textMuted
                                : colors.textPrimary,
                            baselineColor: colors.border,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _VoiceActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.chat_voice_delete_recording,
                      foregroundColor: colors.textMuted,
                      onTap: isSending ? null : onDelete,
                    ),
                  ),
                  Expanded(
                    child: _VoiceActionButton(
                      icon: isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      label: pauseLabel,
                      foregroundColor: colors.primary,
                      onTap: isSending ? null : onTogglePause,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Semantics(
                        button: true,
                        enabled: !isSending,
                        label: l10n.chat_voice_send_recording,
                        child: Tooltip(
                          message: l10n.chat_voice_send_recording,
                          child: InkResponse(
                            radius: 30,
                            onTap: isSending ? null : onSend,
                            child: Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: isSending
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.white,
                                      ),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      color: colors.white,
                                      size: 28,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceActionButton extends StatelessWidget {
  const _VoiceActionButton({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Tooltip(
        message: label,
        child: InkResponse(
          radius: 28,
          onTap: onTap,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icon, color: foregroundColor, size: 30),
          ),
        ),
      ),
    );
  }
}

class _VoiceWaveformPainter extends CustomPainter {
  const _VoiceWaveformPainter({
    required this.amplitudes,
    required this.waveformColor,
    required this.baselineColor,
  });

  final List<double> amplitudes;
  final Color waveformColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    const barWidth = 3.0;
    const barGap = 2.0;
    const minimumBarHeight = 4.0;
    final centerY = size.height / 2;
    final maxBarHeight = math.max(minimumBarHeight, size.height - 4);
    final maxVisibleBars = math.max(
      0,
      ((size.width * 0.34) / (barWidth + barGap)).floor(),
    );
    final visibleSamples = amplitudes.length <= maxVisibleBars
        ? amplitudes
        : amplitudes.sublist(amplitudes.length - maxVisibleBars);
    final waveformPaint = Paint()
      ..color = waveformColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    var x = barWidth / 2;
    for (final sample in visibleSamples) {
      final normalized = sample.clamp(0.0, 1.0).toDouble();
      final barHeight = math.max(minimumBarHeight, maxBarHeight * normalized);
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        waveformPaint,
      );
      x += barWidth + barGap;
    }

    final baselineStart = visibleSamples.isEmpty ? 0.0 : x + 4;
    final baselinePaint = Paint()
      ..color = baselineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    const dashWidth = 2.0;
    const dashGap = 5.0;
    var dashX = baselineStart;
    while (dashX < size.width) {
      canvas.drawLine(
        Offset(dashX, centerY),
        Offset(math.min(size.width, dashX + dashWidth), centerY),
        baselinePaint,
      );
      dashX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) {
    return amplitudes != oldDelegate.amplitudes ||
        waveformColor != oldDelegate.waveformColor ||
        baselineColor != oldDelegate.baselineColor;
  }
}
