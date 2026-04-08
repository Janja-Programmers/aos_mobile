import 'package:africaonlinestores/features/shorts/application/upload/upload_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/short_page.dart';

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    Future.microtask(() {
      ref.read(feedControllerProvider.notifier).loadInitial();
    });

    // 🔥 LISTEN to upload changes
    ref.listen(uploadOrchestratorProvider, (previous, next) {
      if (next.stage == UploadStage.ready) {
        // 🔥 refresh feed when upload completes
        ref.read(feedControllerProvider.notifier).loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedControllerProvider);

    final pool = ref.read(controllerPoolProvider);
    final orchestrator = ref.read(playbackOrchestratorProvider);
    final tracking = ref.read(trackingServiceProvider);

    final coordinator = ref.watch(feedCoordinatorProvider(_pageController));

    // 🔥 CONNECT SYSTEMS
    coordinator.onWindowChanged = (window) {
      final urls = feed.items.map((e) => e.playbackUrl).toList();

      pool.handleWindow(window: window, urls: urls);

      orchestrator.handleWindow(window);

      final active = window.activeIndex;

      if (active < feed.items.length) {
        final short = feed.items[active];

        tracking.trackImpression(short.id);
        tracking.startViewTimer(short.id);
      }
    };

    if (feed.isLoading && feed.items.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (feed.error != null && feed.items.isEmpty) {
      return Scaffold(body: Center(child: Text(feed.error!)));
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: feed.items.length,
        itemBuilder: (context, index) {
          final short = feed.items[index];

          return ShortPage(index: index, shortId: short.id);
        },
      ),
    );
  }
}
