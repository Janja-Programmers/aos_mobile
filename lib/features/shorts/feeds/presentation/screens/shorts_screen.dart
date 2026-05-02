import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_feed_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_session_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/playback/playback_authority.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_session_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/helpers/short_video_cache_provider.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_feed_view.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_page.dart';

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen>
    with WidgetsBindingObserver {
  late final PageController _controller;
  late final PlaybackAuthority _authority;

  bool _initialized = false;

  ProviderSubscription<ShortsFeedState>? _feedSub;
  ProviderSubscription<ShortsSessionState>? _sessionSub;

  late final ShortSessionController _sessionController;
  late final ShortVideoCacheManager _videoCache;

  List<String> _urlsCache = [];
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _controller = PageController(initialPage: 0);

    _sessionController = ref.read(shortSessionControllerProvider.notifier);
    _videoCache = ref.read(shortVideoCacheProvider.notifier);

    _authority = PlaybackAuthority(_videoCache);

    /// ─────────────────────────────────────────────
    /// INITIAL LOAD
    /// ─────────────────────────────────────────────
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialized) return;
      _initialized = true;

      await ref.read(shortsFeedControllerProvider.notifier).loadForYou();
    });

    /// ─────────────────────────────────────────────
    /// FEED → SESSION INIT
    /// ─────────────────────────────────────────────
    _feedSub = ref.listenManual<ShortsFeedState>(shortsFeedControllerProvider, (
      prev,
      next,
    ) {
      final becameReady =
          prev?.status != ShortsFeedStatus.ready &&
          next.status == ShortsFeedStatus.ready;

      if (!becameReady || next.shorts.isEmpty) return;

      _urlsCache = next.shorts.map((e) => e.playbackUrl).toList();

      ref.read(shortSessionControllerProvider.notifier).activate(0);

      appLogger.i("📦 Feed ready → Session initialized");
    });

    /// ─────────────────────────────────────────────
    /// SESSION → AUTHORITY PIPELINE
    /// ─────────────────────────────────────────────
    _sessionSub = ref.listenManual<ShortsSessionState>(
      shortSessionControllerProvider,
      (prev, next) async {
        if (prev == next) return;

        await _authority.onSessionChanged(
          prev: prev ?? next,
          next: next,
          urls: _urlsCache,
        );

        /// UI sync only
        if (_controller.hasClients &&
            _controller.page?.round() != next.activeIndex) {
          _controller.jumpToPage(next.activeIndex);
        }
      },
    );
  }

  /// ─────────────────────────────────────────────
  /// LIFECYCLE (SESSION ONLY)
  /// ─────────────────────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    // final session = ref.read(shortSessionControllerProvider.notifier);

    if (state == AppLifecycleState.paused) {
      appLogger.i("⏸ APP PAUSED");
      _sessionController.pause();
    }

    if (state == AppLifecycleState.resumed) {
      appLogger.i("▶️ APP RESUMED");
      _sessionController.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _feedSub?.close();
    _sessionSub?.close();

    _sessionController.deactivate();
    unawaited(_videoCache.clear());

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final feedState = ref.watch(shortsFeedControllerProvider);

    if (feedState.isLoading) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (feedState.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text("Shorts Unavailable", style: context.h5),
        ),
        backgroundColor: colors.surface,
        body: const Center(child: Text("No shorts available")),
      );
    }

    return Scaffold(
      backgroundColor: colors.black,
      body: SafeArea(
        child: ShortsFeedView(
          controller: _controller,
          itemCount: feedState.shorts.length,

          /// UI → SESSION INTENT ONLY (NO AUTHORITY HERE YET)
          onPageChanged: (index) {
            final direction = index > _lastIndex
                ? ScrollDirection.forward
                : ScrollDirection.reverse;

            _lastIndex = index;

            ref
                .read(shortSessionControllerProvider.notifier)
                .startTransition(index, direction: direction);
          },

          itemBuilder: (context, index) {
            return ShortPage(index: index);
          },
        ),
      ),
    );
  }
}
