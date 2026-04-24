import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// ─────────────────────────────────────────────
/// VIDEO ASPECT HELPER
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// → Provide correct aspect-ratio layout
///

class VideoAspectHelper {
  const VideoAspectHelper();

  Widget buildFittedVideo({required VideoPlayerController controller}) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final aspectRatio = controller.value.aspectRatio;

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  /// Full-screen portrait fit
  Widget buildFullScreenVideo({required VideoPlayerController controller}) {
    if (!controller.value.isInitialized) {
      return const SizedBox.expand(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    final size = controller.value.size;
    final videoAspect = size.width / size.height;

    // ─────────────────────────────────────
    // ADAPTIVE RULE ENGINE (PURE RENDER LOGIC)
    // ─────────────────────────────────────

    BoxFit fit;

    if (videoAspect >= 0.55 && videoAspect <= 0.65) {
      // classic portrait (TikTok ideal range ~9:16 = 0.5625)
      fit = BoxFit.cover;
    } else if (videoAspect < 0.55) {
      // extremely tall (UI-safe crop mode)
      fit = BoxFit.cover;
    } else if (videoAspect > 1.2) {
      // landscape or wide content
      fit = BoxFit.contain;
    } else {
      // fallback balanced crop
      fit = BoxFit.cover;
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: fit,
        alignment: Alignment.center,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
