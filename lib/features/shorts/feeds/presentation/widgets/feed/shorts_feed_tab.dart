import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/following/suggested_sellers_section.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_l10n.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/empty_shorts_view.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/live_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ShortsFeedTab extends ConsumerStatefulWidget {
  const ShortsFeedTab({
    super.key,
    required this.feedType,
    this.contentMode,
    this.categoryLabel,
    this.isActive = true,
  });

  final ShortsFeedType feedType;
  final String? contentMode;
  final String? categoryLabel;
  final bool isActive;

  @override
  ConsumerState<ShortsFeedTab> createState() => _ShortsFeedTabState();
}

class _ShortsFeedTabState extends ConsumerState<ShortsFeedTab> {
  final _scrollController = ScrollController();

  late final ShortsRepository _repository;
  final List<Object> _items = <Object>[];

  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasInitialError = false;
  bool _loadMoreFailed = false;
  int _requestGeneration = 0;

  bool get _canLoadMore {
    return !_isLoading &&
        !_isLoadingMore &&
        !_loadMoreFailed &&
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
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShortsFeedTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    final inputsChanged =
        oldWidget.contentMode != widget.contentMode ||
        oldWidget.feedType != widget.feedType;
    final becameActive = !oldWidget.isActive && widget.isActive;

    if (inputsChanged) {
      unawaited(_loadInitial(force: true));
      _jumpToStart();
      return;
    }

    if (becameActive && _items.isEmpty && !_isLoading) {
      unawaited(_loadInitial());
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

  Future<void> _loadInitial({bool force = false}) async {
    if (_isLoading && !force) return;

    final generation = ++_requestGeneration;
    final feedType = widget.feedType;
    final contentMode = widget.contentMode;

    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _items.clear();
      _nextCursor = null;
      _hasMore = true;
      _hasInitialError = false;
      _loadMoreFailed = false;
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
        _hasInitialError = true;
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
        final existingKeys = _items.map(_itemKey).toSet();
        for (final item in page.items) {
          if (existingKeys.add(_itemKey(item))) {
            _items.add(item);
          }
        }
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _loadMoreFailed = false;
      });
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Feed pagination failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() => _loadMoreFailed = true);
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _retryLoadMore() async {
    if (_isLoading || _isLoadingMore) return;
    setState(() => _loadMoreFailed = false);
    await _loadMore();
  }

  Object _itemKey(Object item) {
    if (item is LiveStream) return 'live:${item.id}';
    if (item is Short) return 'short:${item.id.value}';
    return item;
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_canLoadMore) return;
    if (_scrollController.position.extentAfter < 700) {
      unawaited(_loadMore());
    }
  }

  void _jumpToStart() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _openShortDetail(Short short) {
    final shorts = _items.whereType<Short>().toList(growable: false);
    final shortIndex = shorts.indexWhere(
      (candidate) => candidate.id.value == short.id.value,
    );
    if (shortIndex < 0) return;

    ShortsNavigation.toShortDetail(
      context,
      initialShorts: shorts,
      initialIndex: shortIndex,
      initialNextCursor: _nextCursor,
      initialHasMore: _hasMore,
    );
  }

  Widget _buildContentItem(BuildContext context, int index) {
    final item = _items[index];

    if (item is LiveStream) {
      return RepaintBoundary(
        key: ValueKey('live_${item.id}'),
        child: LiveCard(
          live: item,
          onTap: () => LiveNavigation.toLiveRoom(context, liveId: item.id),
        ),
      );
    }

    final short = item as Short;
    return RepaintBoundary(
      key: ValueKey('short_${short.id.value}'),
      child: ShortCard(short: short, onTap: () => _openShortDetail(short)),
    );
  }

  Widget _buildMasonryItem(BuildContext context, int index) {
    if (index < _items.length) {
      return _buildContentItem(context, index);
    }

    return _PaginationFooter(
      isLoading: _isLoadingMore,
      hasError: _loadMoreFailed,
      onRetry: () => unawaited(_retryLoadMore()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isLoading && _items.isEmpty) {
      if (_hasInitialError) {
        return _InitialErrorView(onRetry: () => unawaited(_loadInitial()));
      }

      return EmptyShortsView(
        feedType: widget.feedType,
        categoryLabel: widget.categoryLabel,
        hasCategoryFilter: widget.contentMode != null,
        onRefresh: _loadInitial,
      );
    }

    return switch (widget.feedType) {
      ShortsFeedType.following => _buildFollowingFeed(context),
      ShortsFeedType.live => _buildLiveFeed(context),
      ShortsFeedType.forYou => _buildShortsGrid(context),
    };
  }

  Widget _buildShortsGrid(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: MasonryGridView.count(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _items.length + (_isLoadingMore || _loadMoreFailed ? 1 : 0),
        itemBuilder: _buildMasonryItem,
      ),
    );
  }

  Widget _buildFollowingFeed(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView(
        scrollCacheExtent: const ScrollCacheExtent.pixels(900),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const SuggestedSellersSection(),
          const SizedBox(height: 22),
          Text(
            context.l10n.feedFollowingShorts,
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
            itemCount: _items.length,
            itemBuilder: _buildContentItem,
          ),
          if (_isLoadingMore || _loadMoreFailed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _PaginationFooter(
                isLoading: _isLoadingMore,
                hasError: _loadMoreFailed,
                onRetry: () => unawaited(_retryLoadMore()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveFeed(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            sliver: SliverToBoxAdapter(
              child: _LiveSectionHeader(
                isRefreshing: _isLoading,
                onRefresh: () => unawaited(_loadInitial()),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .75,
              ),
              delegate: SliverChildBuilderDelegate(
                _buildContentItem,
                childCount: _items.length,
              ),
            ),
          ),
          if (_isLoadingMore || _loadMoreFailed)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              sliver: SliverToBoxAdapter(
                child: _PaginationFooter(
                  isLoading: _isLoadingMore,
                  hasError: _loadMoreFailed,
                  onRetry: () => unawaited(_retryLoadMore()),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _InitialErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _InitialErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 36, color: colors.textMuted),
              const SizedBox(height: 12),
              Text(
                context.l10n.feedCouldNotLoad,
                textAlign: TextAlign.center,
                style: context.p,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(context.l10n.feedTryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  const _PaginationFooter({
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 64,
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!hasError) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Center(
          child: TextButton(
            onPressed: onRetry,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded),
                const SizedBox(height: 4),
                Text(
                  '${context.l10n.feedCouldNotLoadMore} ${context.l10n.feedTryAgain}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveSectionHeader extends StatelessWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const _LiveSectionHeader({
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.podcasts_rounded, size: 20, color: colors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.feedLiveNow,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.h6.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.feedLiveNowSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.p.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: l10n.feedRefreshLives,
          child: IconButton(
            onPressed: isRefreshing ? null : onRefresh,
            tooltip: l10n.feedRefreshLives,
            icon: isRefreshing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            style: IconButton.styleFrom(
              minimumSize: const Size.square(48),
              backgroundColor: colors.border.withValues(alpha: .28),
              foregroundColor: colors.textPrimary,
              disabledForegroundColor: colors.textMuted,
              shape: const CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
