import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_feed_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_session_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_feed_view.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_page.dart';

/// ─────────────────────────────────────────────
/// SHORTS SCREEN
/// ─────────────────────────────────────────────
///
/// BOOT FLOW:
/// → Wait for feed
/// → Build PageView
/// → PageView drives session (single source of truth)
///

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen>
    with WidgetsBindingObserver {
  late final PageController _controller;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    appLogger.i("🟡 ShortsScreen.initState");

    WidgetsBinding.instance.addObserver(this);

    _controller = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();

      final feedState = ref.read(shortsFeedControllerProvider);

      if (feedState.shorts.isNotEmpty) {
        ref.read(shortSessionControllerProvider.notifier).activate(0);
      }
    });

    /// Safe listener (NOT inside build)
    ref.listenManual(shortsFeedControllerProvider, (prev, next) {
      if (prev?.isLoading == true && next.isLoading == false) {
        if (next.shorts.isNotEmpty) {
          /// Optional safety bootstrap ONLY if needed
          ref.read(shortSessionControllerProvider.notifier).activate(0);
        }
      }
    });
  }

  void _bootstrap() {
    appLogger.i("🟡 ShortsScreen._bootstrap called");
    if (_initialized) return;
    _initialized = true;

    /// IMPORTANT:
    /// Do NOT activate session here anymore if PageView is source of truth
  }

  /// ─────────────────────────────
  /// APP LIFECYCLE HANDLING
  /// ─────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sessionController = ref.read(shortSessionControllerProvider.notifier);

    if (state == AppLifecycleState.paused) {
      sessionController.pause();
    }

    if (state == AppLifecycleState.resumed) {
      sessionController.resume();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final feedState = ref.watch(shortsFeedControllerProvider);

    appLogger.i("🔥 RAW SHORTS LIST: ${feedState.shorts}");

    appLogger.i(
      "🟢 ShortsScreen.build | isLoading=${feedState.isLoading} | isEmpty=${feedState.isEmpty} | count=${feedState.shorts.length}",
    );

    /// Loading state
    if (feedState.isLoading) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    /// Empty state
    if (feedState.isEmpty) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(child: Text("No shorts available", style: context.p)),
      );
    }

    appLogger.i(
      "📊 FEED STATE | loading=${feedState.isLoading} | empty=${feedState.isEmpty} | shorts=${feedState.shorts.length}",
    );

    /// Ready state
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: Text("Shorts & Live", style: context.h4),
      ),
      backgroundColor: colors.surface,
      body: SafeArea(
        child: ShortsFeedView(
          controller: _controller,
          itemCount: feedState.shorts.length,

          /// SINGLE SOURCE OF TRUTH FOR SESSION
          onPageChanged: (index) {
            ref.read(shortSessionControllerProvider.notifier).activate(index);
          },

          itemBuilder: (context, index) {
            return ShortPage(index: index);
          },
        ),
      ),
    );
  }
}
