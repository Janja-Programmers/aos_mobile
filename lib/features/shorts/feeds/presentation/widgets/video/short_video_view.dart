import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/short_video_cache_provider.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/video_aspect_helper.dart';

/// ─────────────────────────────────────────────
/// SHORT VIDEO VIEW (PURE RENDER LAYER)
/// ─────────────────────────────────────────────
///
/// RESPONSIBILITY:
/// → Render VideoPlayerController only
/// → No playback logic
/// → No session awareness
/// → No cache mutation
///

class ShortVideoView extends ConsumerWidget {
  final int index;

  const ShortVideoView({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cache = ref.watch(shortVideoCacheProvider);

    final controller = cache.controllerFor(index);

    /// No controller yet → render safe placeholder
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    }

    final aspect = const VideoAspectHelper();

    return SizedBox.expand(
      child: aspect.buildFullScreenVideo(controller: controller),
    );
  }
}
