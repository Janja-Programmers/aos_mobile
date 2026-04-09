import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/shorts/short_page.dart';
import 'package:africaonlinestores/features/shorts/application/state/upload_state.dart';

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

    // Load feed once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shortsControllerProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Reload feed after upload success
    ref.listen<UploadState>(postShortControllerProvider, (prev, next) {
      if (next.isReady) {
        ref.read(shortsControllerProvider.notifier).loadInitial();
      }
    });

    final state = ref.watch(shortsControllerProvider);

    // ───────────── LOADING ─────────────
    if (state.isLoading && state.shorts.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ───────────── EMPTY ─────────────
    if (!state.isLoading && state.shorts.isEmpty) {
      return const Scaffold(body: Center(child: Text("No videos found")));
    }

    // ───────────── MAIN UI ─────────────
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: state.shorts.length,
        onPageChanged: (index) {
          ref.read(shortsControllerProvider.notifier).onPageChanged(index);
        },
        itemBuilder: (context, index) {
          final short = state.shorts[index];

          return ShortPage(index: index, short: short);
        },
      ),
    );
  }
}
