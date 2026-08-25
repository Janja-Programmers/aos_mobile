import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class InlineAudioPlayer extends StatefulWidget {
  final String url;

  const InlineAudioPlayer({super.key, required this.url});

  @override
  State<InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<InlineAudioPlayer> {
  final AudioPlayer player = AudioPlayer();

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();

    unawaited(_loadAudio());

    _durationSubscription = player.durationStream.listen((d) {
      if (mounted && d != null) {
        setState(() => duration = d);
      }
    });

    _positionSubscription = player.positionStream.listen((p) {
      if (mounted) setState(() => position = p);
    });

    _playerStateSubscription = player.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadAudio() async {
    await player.setUrl(widget.url);
  }

  @override
  void dispose() {
    unawaited(_durationSubscription?.cancel());
    unawaited(_positionSubscription?.cancel());
    unawaited(_playerStateSubscription?.cancel());
    unawaited(player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ▶ PLAY BUTTON
          IconButton(
            icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (player.playing) {
                unawaited(player.pause());
              } else {
                unawaited(player.play());
              }
              setState(() {});
            },
          ),

          // 📊 PROGRESS BAR
          Expanded(
            child: Slider(
              max: duration.inSeconds.toDouble().clamp(1, double.infinity),
              value: position.inSeconds.toDouble().clamp(
                0,
                duration.inSeconds.toDouble(),
              ),
              onChanged: (value) {
                unawaited(player.seek(Duration(seconds: value.toInt())));
              },
            ),
          ),

          // ⏱ TIME
          Text(_format(position), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.toString();
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
