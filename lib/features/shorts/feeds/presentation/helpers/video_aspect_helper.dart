import 'package:flutter/widgets.dart';
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
      return const SizedBox.shrink();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
