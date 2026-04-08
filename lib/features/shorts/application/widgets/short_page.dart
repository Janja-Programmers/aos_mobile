import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:africaonlinestores/features/shorts/application/metrics/metrics_provider.dart';
import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart'
    hide metricsNotifierProvider;
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

class ShortPage extends ConsumerWidget {
  final int index;
  final ShortId shortId;

  const ShortPage({super.key, required this.index, required this.shortId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pool = ref.read(controllerPoolProvider);

    final entry = pool.get(index);

    final liked = ref.watch(shortLikedProvider(shortId));
    final likeCount = ref.watch(shortLikeCountProvider(shortId));

    return Stack(
      fit: StackFit.expand,
      children: [
        // 🎥 VIDEO
        _buildVideo(entry),

        // ❤️ UI OVERLAY
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: liked ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  ref
                      .read(metricsNotifierProvider.notifier)
                      .toggleLikeOptimistic(shortId);
                },
              ),
              Text('$likeCount', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideo(entry) {
    if (entry == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = entry.controller;

    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
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
