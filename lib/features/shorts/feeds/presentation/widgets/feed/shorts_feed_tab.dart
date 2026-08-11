import 'dart:async';

import 'package:africaonlinestores/core/media/livekit_track_events.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/following/suggested_sellers_section.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/empty_shorts_view.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/live_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class ShortsFeedTab extends ConsumerStatefulWidget {
  final ShortsFeedType feedType;
  final String? contentMode;
  final String? categoryLabel;
  final bool isActive;

  const ShortsFeedTab({
    super.key,
    required this.feedType,
    this.contentMode,
    this.categoryLabel,
    this.isActive = true,
  });

  @override
  ConsumerState<ShortsFeedTab> createState() => _ShortsFeedTabState();
}

class _ShortsFeedTabState extends ConsumerState<ShortsFeedTab> {
  final _scrollController = ScrollController();
  final _pageController = PageController();

  late final ShortsRepository _repository;

  final List<Object> _items = [];

  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _requestGeneration = 0;
  StreamSubscription<MediaTrackEvent>? _mediaSubscription;
  lk.RemoteVideoTrack? _remoteVideoTrack;
  String? _activeLiveId;
  int _activeLiveIndex = 0;

  bool get _canLoadMore {
    return !_isLoading &&
        !_isLoadingMore &&
        _hasMore &&
        (_nextCursor?.trim().isNotEmpty ?? false);
  }

  @override
  void initState() {
    super.initState();

    _repository = ShortsRepository(
      ref.read(shortsFeedApiProvider),
      ref.read(liveApiProvider),
    );

    unawaited(_loadInitial());
    _scrollController.addListener(_onScroll);
    if (widget.feedType == ShortsFeedType.live) {
      final liveKit = ref.read(liveKitCoreProvider);
      _mediaSubscription = liveKit.events.listen(_onMediaEvent);
      liveKit.emitCurrentTracks();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _pageController.dispose();
    unawaited(_mediaSubscription?.cancel());
    final activeLiveId = _activeLiveId;
    if (activeLiveId != null) {
      unawaited(
        ref
            .read(liveManagerProvider.notifier)
            .leaveBackgroundLive(activeLiveId),
      );
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShortsFeedTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.contentMode != widget.contentMode ||
        oldWidget.feedType != widget.feedType) {
      _deactivateVisibleLive();
      unawaited(_loadInitial());

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }

    if (oldWidget.isActive != widget.isActive &&
        widget.feedType == ShortsFeedType.live) {
      if (widget.isActive) {
        unawaited(_activateVisibleLive(_activeLiveIndex));
      } else {
        _deactivateVisibleLive();
      }
    }
  }

  Future<({List<Object> items, String? nextCursor, bool hasMore})> _fetchPage({
    required ShortsFeedType feedType,
    required String? contentMode,
    String? cursor,
  }) async {
    switch (feedType) {
      case ShortsFeedType.forYou:
        final page = await _repository.fetchForYou(
          cursor: cursor,
          contentMode: contentMode,
        );
        return (
          items: <Object>[...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        );

      case ShortsFeedType.following:
        final page = await _repository.fetchFollowing(
          cursor: cursor,
          contentMode: contentMode,
        );
        return (
          items: <Object>[...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        );

      case ShortsFeedType.live:
        final page = await _repository.fetchLive(cursor: cursor);
        return (
          items: <Object>[...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        );
    }
  }

  Future<void> _loadInitial() async {
    final generation = ++_requestGeneration;
    final feedType = widget.feedType;
    final contentMode = widget.contentMode;

    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _items.clear();
      _nextCursor = null;
      _hasMore = true;
      _errorMessage = null;
    });

    try {
      final page = await _fetchPage(
        feedType: feedType,
        contentMode: contentMode,
      );

      if (!mounted || generation != _requestGeneration) return;

      setState(() {
        _items.addAll(page.items);
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
      if (feedType == ShortsFeedType.live && widget.isActive) {
        await _activateVisibleLive(0);
      }
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Feed initial load failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || generation != _requestGeneration) return;

      setState(() {
        _items.clear();
        _nextCursor = null;
        _hasMore = false;
        _errorMessage = 'Could not load this feed.';
      });
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_canLoadMore) return;

    final cursor = _nextCursor?.trim();

    if (cursor == null || cursor.isEmpty) return;

    final generation = _requestGeneration;
    final feedType = widget.feedType;
    final contentMode = widget.contentMode;

    setState(() => _isLoadingMore = true);

    try {
      final page = await _fetchPage(
        feedType: feedType,
        contentMode: contentMode,
        cursor: cursor,
      );

      if (!mounted || generation != _requestGeneration) return;

      setState(() {
        _items.addAll(page.items);
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Feed pagination failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!_canLoadMore) return;

    final extentAfter = _scrollController.position.extentAfter;

    if (extentAfter < 700) {
      unawaited(_loadMore());
    }
  }

  void _onMediaEvent(MediaTrackEvent event) {
    if (!mounted || widget.feedType != ShortsFeedType.live) return;
    if (event is RemoteVideoTrackEvent) {
      if (_remoteVideoTrack == null) {
        setState(() => _remoteVideoTrack = event.track);
      }
      return;
    }
    if (event is RemoteVideoRemovedEvent || event is TrackClearedEvent) {
      setState(() => _remoteVideoTrack = null);
    }
  }

  Future<void> _activateVisibleLive(int index) async {
    if (!mounted ||
        !widget.isActive ||
        widget.feedType != ShortsFeedType.live ||
        index < 0 ||
        index >= _items.length) {
      return;
    }

    final live = _items[index];
    if (live is! LiveStream ||
        !live.isActive ||
        live.viewerState.isHost ||
        !live.viewerState.canWatch ||
        !live.viewerState.canJoin) {
      _deactivateVisibleLive();
      return;
    }

    _activeLiveIndex = index;
    if (_activeLiveId != live.id) {
      setState(() {
        _activeLiveId = live.id;
        _remoteVideoTrack = null;
      });
    }

    final joined = await ref
        .read(liveManagerProvider.notifier)
        .joinLive(liveId: live.id, showLiveUi: false);
    if (!mounted || _activeLiveId != live.id || !widget.isActive) {
      return;
    }
    if (!joined) {
      setState(() {
        _activeLiveId = null;
        _remoteVideoTrack = null;
      });
      return;
    }
    ref.read(liveKitCoreProvider).emitCurrentTracks();
  }

  void _deactivateVisibleLive() {
    final liveId = _activeLiveId;
    _activeLiveId = null;
    _remoteVideoTrack = null;
    if (liveId == null) return;
    unawaited(
      ref.read(liveManagerProvider.notifier).leaveBackgroundLive(liveId),
    );
  }

  void _onLivePageChanged(int index) {
    _activeLiveIndex = index;
    unawaited(_activateVisibleLive(index));
    if (index >= _items.length - 3) unawaited(_loadMore());
  }

  void _openDetail(int index) {
    if (widget.feedType == ShortsFeedType.live) {
      return;
    }

    final shorts = _items.whereType<Short>().toList();

    ShortsNavigation.toShortDetail(
      context,
      initialShorts: shorts,
      initialIndex: index,
      initialNextCursor: _nextCursor,
      initialHasMore: _hasMore,
    );
  }

  Widget _buildShortItem(BuildContext context, int index) {
    if (index >= _items.length) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final item = _items[index];

    if (item is LiveStream) {
      return RepaintBoundary(
        key: ValueKey('live_${item.id}'),
        child: LiveCard(
          live: item,
          isActive: _activeLiveId == item.id,
          remoteVideoTrack: _activeLiveId == item.id ? _remoteVideoTrack : null,
          fullScreen: widget.feedType == ShortsFeedType.live,
          onTap: () {
            LiveNavigation.toLiveRoom(context, liveId: item.id);
          },
        ),
      );
    }

    final short = item as Short;

    return RepaintBoundary(
      key: ValueKey('short_${short.id.value}'),
      child: ShortCard(short: short, onTap: () => _openDetail(index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isLoading && _items.isEmpty) {
      if (_errorMessage != null) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: context.p,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => unawaited(_loadInitial()),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      }
      return EmptyShortsView(
        feedType: widget.feedType,
        categoryLabel: widget.categoryLabel,
        onRefresh: _loadInitial,
      );
    }

    if (widget.feedType == ShortsFeedType.following) {
      return ListView(
        scrollCacheExtent: const ScrollCacheExtent.pixels(900),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          const SuggestedSellersSection(),

          const SizedBox(height: 22),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Following Shorts',
                style: context.h6.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),

              MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: _buildShortItem,
              ),
            ],
          ),
        ],
      );
    }

    if (widget.feedType == ShortsFeedType.live) {
      return Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _items.length,
            onPageChanged: _onLivePageChanged,
            itemBuilder: _buildShortItem,
          ),
          if (_isLoadingMore)
            const PositionedDirectional(
              end: 16,
              bottom: 16,
              child: SafeArea(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      );
    }

    return MasonryGridView.count(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: _buildShortItem,
    );
  }
}
