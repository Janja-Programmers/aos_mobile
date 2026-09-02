import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

Future<void> showShortSoundDialog(
  BuildContext context, {
  required Short short,
}) async {
  final sound = short.sound;
  final reusable = sound != null && !sound.isOriginal && !sound.isOriginalAudio;

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .58),
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: _ShortSoundDialogBody(
          sound: reusable ? sound : null,
          onUseSound: (selectedSound) {
            Navigator.pop(dialogContext);
            unawaited(
              context.pushNamed<void>(
                AppRoutes.nPostShort,
                extra: selectedSound,
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _ShortSoundDialogBody extends StatelessWidget {
  const _ShortSoundDialogBody({required this.sound, required this.onUseSound});

  final ShortSound? sound;
  final ValueChanged<ShortSound> onUseSound;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selectedSound = sound;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text('Sound', style: context.h6)),
              IconButton(
                tooltip: 'Close sound details',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(
            'Audio used by this Short.',
            style: context.small.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 18),
          if (selectedSound == null)
            Text(
              'This Short uses its original audio.',
              style: context.p.copyWith(color: colors.textMuted),
            )
          else ...<Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: colors.black,
                          child: Icon(
                            Icons.music_note_rounded,
                            color: colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                selectedSound.title,
                                style: context.pStrong,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (selectedSound.artist.trim().isNotEmpty)
                                Text(
                                  selectedSound.artist.trim(),
                                  style: context.small.copyWith(
                                    color: colors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (selectedSound.isPlayable) ...<Widget>[
                      const SizedBox(height: 12),
                      _SoundPreviewPlayer(sound: selectedSound),
                    ],
                    const SizedBox(height: 14),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        foregroundColor: colors.white,
                      ),
                      onPressed: () => onUseSound(selectedSound),
                      child: Text(
                        'Use this sound',
                        style: AppTextStylesX(
                          context,
                        ).button.copyWith(color: colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SoundPreviewPlayer extends StatefulWidget {
  const _SoundPreviewPlayer({required this.sound});

  final ShortSound sound;

  @override
  State<_SoundPreviewPlayer> createState() => _SoundPreviewPlayerState();
}

class _SoundPreviewPlayerState extends State<_SoundPreviewPlayer> {
  late final AudioPlayer _player;
  Duration _duration = Duration.zero;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final url = widget.sound.fileUrl?.trim() ?? '';
    if (url.isEmpty) return;
    try {
      final duration = await _player.setUrl(url);
      if (!mounted) return;
      setState(() => _duration = duration ?? Duration.zero);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (_failed) {
      return Text(
        'Preview unavailable.',
        style: context.small.copyWith(color: colors.textMuted),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            StreamBuilder<bool>(
              stream: _player.playingStream,
              initialData: false,
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;
                return IconButton(
                  tooltip: playing
                      ? 'Pause sound preview'
                      : 'Play sound preview',
                  onPressed: _duration == Duration.zero
                      ? null
                      : () {
                          if (playing) {
                            unawaited(_player.pause());
                          } else {
                            unawaited(_player.play());
                          }
                        },
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                );
              },
            ),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _player.positionStream,
                initialData: Duration.zero,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final maxMs = _duration.inMilliseconds <= 0
                      ? 1
                      : _duration.inMilliseconds;
                  final value = position.inMilliseconds
                      .clamp(0, maxMs)
                      .toDouble();
                  return Slider(
                    max: maxMs.toDouble(),
                    value: value,
                    onChanged: _duration == Duration.zero
                        ? null
                        : (next) => unawaited(
                            _player.seek(Duration(milliseconds: next.round())),
                          ),
                  );
                },
              ),
            ),
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              initialData: Duration.zero,
              builder: (context, snapshot) => Text(
                '${_format(snapshot.data ?? Duration.zero)} / ${_format(_duration)}',
                style: context.small.copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
