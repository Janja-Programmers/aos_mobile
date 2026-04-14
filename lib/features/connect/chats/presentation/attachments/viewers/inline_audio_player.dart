import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:africaonlinestores/core/core.dart';

class InlineAudioPlayer extends StatefulWidget {
  final String url;

  const InlineAudioPlayer({super.key, required this.url});

  @override
  State<InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<InlineAudioPlayer> {
  final player = AudioPlayer();

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.setUrl(widget.url);

    player.durationStream.listen((d) {
      if (d != null) {
        setState(() => duration = d);
      }
    });

    player.positionStream.listen((p) {
      setState(() => position = p);
    });
  }

  @override
  void dispose() {
    player.dispose();
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
              player.playing ? player.pause() : player.play();
              setState(() {});
            },
          ),

          // 📊 PROGRESS BAR
          Expanded(
            child: Slider(
              min: 0,
              max: duration.inSeconds.toDouble().clamp(1, double.infinity),
              value: position.inSeconds.toDouble().clamp(
                0,
                duration.inSeconds.toDouble(),
              ),
              onChanged: (value) {
                player.seek(Duration(seconds: value.toInt()));
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
    return "$minutes:$seconds";
  }
}
