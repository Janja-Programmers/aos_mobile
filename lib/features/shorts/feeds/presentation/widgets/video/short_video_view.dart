import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';

import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/short_video_cache_provider.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/video_aspect_helper.dart';

/// ─────────────────────────────────────────────
/// SHORT VIDEO VIEW (PURE RENDER LAYER)
/// ─────────────────────────────────────────────
///
/// RESPONSIBILITY:
/// ✔ Render VideoPlayerController only
/// ✔ React to controller lifecycle state
/// ✔ Show safe UI while controller initializes/fails
///
/// DOES NOT:
/// ❌ create controllers
/// ❌ play/pause videos
/// ❌ decide active index
/// ❌ compute preload windows
/// ❌ mutate cache/session state
///

class ShortVideoView extends ConsumerWidget {
  final int index;

  const ShortVideoView({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(shortVideoControllerStateProvider(index));
    final colors = context.appColors;

    /// No controller state yet → authority has not prepared this index.
    if (videoState == null) {
      return SizedBox.expand(child: ColoredBox(color: colors.black));
    }

    /// Controller is being initialized → show loading state instead of silent black.
    if (videoState.isInitializing) {
      return SizedBox.expand(
        child: ColoredBox(
          color: colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    /// Controller failed to initialize → show safe fallback.
    if (videoState.error != null) {
      return SizedBox.expand(
        child: ColoredBox(
          color: colors.black,
          child: Center(child: Icon(Icons.error_outline, color: colors.white)),
        ),
      );
    }

    final controller = videoState.controller;

    /// State exists, but controller is not usable.
    if (controller == null ||
        !videoState.isReady ||
        !controller.value.isInitialized) {
      return SizedBox.expand(child: ColoredBox(color: colors.black));
    }

    final aspect = const VideoAspectHelper();

    return SizedBox.expand(
      child: aspect.buildFullScreenVideo(controller: controller),
    );
  }
}
