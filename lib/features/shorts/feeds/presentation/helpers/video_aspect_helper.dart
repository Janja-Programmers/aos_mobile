import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// ─────────────────────────────────────────────
/// VIDEO ASPECT HELPER
/// ─────────────────────────────────────────────
///
/// SINGLE RESPONSIBILITY:
/// ✔ Render video with correct aspect-ratio behavior
///
/// DOES NOT:
/// ❌ control playback
/// ❌ know active index
/// ❌ mutate video state
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

  /// ─────────────────────────────────────────────
  /// FULL-SCREEN SHORTS VIDEO
  /// ─────────────────────────────────────────────
  ///
  /// Rule:
  /// - Preserve video aspect ratio
  /// - Fill the screen edge-to-edge
  /// - Never stretch the video
  /// - Crop overflow like TikTok/Reels
  ///
  Widget buildFullScreenVideo({required VideoPlayerController controller}) {
    if (!controller.value.isInitialized) {
      return const SizedBox.expand();
    }

    final size = controller.value.size;

    if (size.width <= 0 || size.height <= 0) {
      return const SizedBox.expand();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
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
