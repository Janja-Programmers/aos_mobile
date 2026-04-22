import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_feed_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_interaction_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_session_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/selectors/short_selectors.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/short_video_cache_provider.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/video_aspect_helper.dart';

/// ─────────────────────────────────────────────
/// SHORT VIDEO VIEW
/// ─────────────────────────────────────────────

class ShortVideoView extends ConsumerStatefulWidget {
  final int index;

  const ShortVideoView({super.key, required this.index});

  @override
  ConsumerState<ShortVideoView> createState() => _ShortVideoViewState();
}

class _ShortVideoViewState extends ConsumerState<ShortVideoView> {
  final _selectors = const ShortsSelectors();
  final _aspectHelper = const VideoAspectHelper();

  @override
  void initState() {
    super.initState();
    appLogger.i("🎬 ShortVideoView.initState | index=${widget.index}");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appLogger.i("🎬 didChangeDependencies | index=${widget.index}");

    _syncPlayback();
  }

  @override
  void didUpdateWidget(covariant ShortVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    appLogger.i(
      "🎬 didUpdateWidget | old=${oldWidget.index} → new=${widget.index}",
    );

    _syncPlayback();
  }

  Future<void> _syncPlayback() async {
    appLogger.i("🔄 _syncPlayback START | index=${widget.index}");

    final feed = ref.read(shortsFeedControllerProvider);
    final session = ref.read(shortSessionControllerProvider);
    final cache = ref.read(shortVideoCacheProvider);

    appLogger.i(
      "📦 FEED STATE | shorts=${feed.shorts.length} | active=${session.activeIndex}",
    );

    if (feed.shorts.isEmpty) {
      appLogger.i("❌ FEED EMPTY → abort syncPlayback");
      return;
    }

    final urls = feed.shorts.map((s) => s.playbackUrl).toList();

    final muted = !_selectors.shouldPlayVideo(
      session: session,
      interaction: ref.read(shortInteractionControllerProvider),
    );

    appLogger.i(
      "🎯 CACHE UPDATE | activeIndex=${session.activeIndex} | muted=$muted | urls=${urls.length}",
    );

    try {
      await cache.updateWindow(
        activeIndex: session.activeIndex,
        urls: urls,
        muted: muted,
      );

      appLogger.i("✅ CACHE UPDATE SUCCESS | index=${widget.index}");
    } catch (e, st) {
      appLogger.i("❌ CACHE UPDATE FAILED | $e");
      appLogger.i("STACKTRACE: $st");
    }

    if (mounted) {
      appLogger.i("🔁 setState triggered | index=${widget.index}");
      setState(() {});
    } else {
      appLogger.i("⚠️ widget not mounted after sync");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cache = ref.watch(shortVideoCacheProvider);

    final controller = cache.controllerFor(widget.index);

    appLogger.i(
      "🧱 BUILD | index=${widget.index} | controllerExists=${controller != null}",
    );

    if (controller == null) {
      appLogger.i("❌ NULL CONTROLLER | index=${widget.index}");
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    }

    if (!controller.value.isInitialized) {
      appLogger.i("⏳ NOT INITIALIZED | index=${widget.index}");
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    }

    appLogger.i("▶️ VIDEO READY | index=${widget.index}");

    return SizedBox.expand(
      child: _aspectHelper.buildFullScreenVideo(controller: controller),
    );
  }
}
