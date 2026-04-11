import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class LiveVideoStage extends StatelessWidget {
  final lk.VideoTrack? track;
  final String emptyLabel;
  final bool mirror;

  const LiveVideoStage({
    super.key,
    required this.track,
    required this.emptyLabel,
    this.mirror = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.black,
      alignment: Alignment.center,
      child: track != null
          ? lk.VideoTrackRenderer(
              track!,
              fit: lk.VideoViewFit.contain,
              mirrorMode: mirror
                  ? lk.VideoViewMirrorMode.mirror
                  : lk.VideoViewMirrorMode.off,
            )
          : Text(emptyLabel, style: context.body.copyWith(color: colors.white)),
    );
  }
}
