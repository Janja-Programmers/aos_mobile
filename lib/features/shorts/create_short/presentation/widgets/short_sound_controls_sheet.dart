import 'dart:math' as math;

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:flutter/material.dart';

Future<ShortSound?> showShortSoundControlsSheet(
  BuildContext context, {
  required ShortSound sound,
  required Duration clipDuration,
}) {
  if (sound.isOriginal) return Future<ShortSound?>.value(sound);

  return showModalBottomSheet<ShortSound>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) =>
        _ShortSoundControlsSheet(sound: sound, clipDuration: clipDuration),
  );
}

class _ShortSoundControlsSheet extends StatefulWidget {
  const _ShortSoundControlsSheet({
    required this.sound,
    required this.clipDuration,
  });

  final ShortSound sound;
  final Duration clipDuration;

  @override
  State<_ShortSoundControlsSheet> createState() =>
      _ShortSoundControlsSheetState();
}

class _ShortSoundControlsSheetState extends State<_ShortSoundControlsSheet> {
  late double _startSeconds;
  late double _segmentSeconds;
  late double _volume;

  double get _clipSeconds => math.max(
    .1,
    widget.clipDuration.inMilliseconds / Duration.millisecondsPerSecond,
  );

  double get _soundSeconds => widget.sound.durationSeconds > 0
      ? widget.sound.durationSeconds
      : _clipSeconds;

  double get _maxSegmentSeconds =>
      math.max(.1, math.min(_soundSeconds, _clipSeconds));

  double get _maxStartSeconds => math.max(0, _soundSeconds - _segmentSeconds);

  @override
  void initState() {
    super.initState();
    final initialSegment = widget.sound.durationMs > 0
        ? widget.sound.durationMs / Duration.millisecondsPerSecond
        : _maxSegmentSeconds;
    _segmentSeconds = initialSegment.clamp(.1, _maxSegmentSeconds).toDouble();
    _startSeconds = (widget.sound.startMs / Duration.millisecondsPerSecond)
        .clamp(0, math.max(0, _soundSeconds - _segmentSeconds))
        .toDouble();
    _volume = widget.sound.volume.clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Sound controls', style: context.h5),
                      const SizedBox(height: 4),
                      Text(
                        'Choose where the sound starts and how loud it plays.',
                        style: context.pMuted,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close sound controls',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceBright,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.sound.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.pStrong,
                        ),
                        if (widget.sound.artist.trim().isNotEmpty)
                          Text(
                            widget.sound.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.pMuted,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _ControlHeader(
              label: 'Start position',
              value: _formatSeconds(_startSeconds),
            ),
            Slider(
              value: _startSeconds.clamp(0, _maxStartSeconds).toDouble(),
              max: math.max(.001, _maxStartSeconds),
              onChanged: _maxStartSeconds <= 0
                  ? null
                  : (value) => setState(() => _startSeconds = value),
            ),
            const SizedBox(height: 12),
            _ControlHeader(
              label: 'Sound segment length',
              value: _formatSeconds(_segmentSeconds),
            ),
            Slider(
              value: _segmentSeconds.clamp(.1, _maxSegmentSeconds).toDouble(),
              min: .1,
              max: _maxSegmentSeconds,
              onChanged: _maxSegmentSeconds <= .1
                  ? null
                  : (value) {
                      setState(() {
                        _segmentSeconds = value;
                        _startSeconds = _startSeconds
                            .clamp(0, _maxStartSeconds)
                            .toDouble();
                      });
                    },
            ),
            const SizedBox(height: 12),
            _ControlHeader(
              label: 'Sound volume',
              value: '${(_volume * 100).round()}%',
              icon: Icons.volume_up_outlined,
            ),
            Slider(
              value: _volume,
              divisions: 100,
              onChanged: (value) => setState(() => _volume = value),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, ShortSound.original),
                  icon: const Icon(Icons.music_off_outlined),
                  label: const Text('Remove sound'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      widget.sound.copyWith(
                        startMs: (_startSeconds * 1000).round(),
                        durationMs: (_segmentSeconds * 1000).round(),
                        volume: _volume,
                      ),
                    );
                  },
                  child: Text('Apply', style: AppTextStylesX(context).button),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSeconds(double seconds) {
    final totalTenths = (seconds * 10).round();
    final minutes = totalTenths ~/ 600;
    final wholeSeconds = (totalTenths ~/ 10) % 60;
    final tenths = totalTenths % 10;
    return '$minutes:${wholeSeconds.toString().padLeft(2, '0')}.$tenths';
  }
}

class _ControlHeader extends StatelessWidget {
  const _ControlHeader({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(label, style: context.pStrong)),
        Text(value, style: context.pStrong.copyWith(color: colors.primary)),
      ],
    );
  }
}
