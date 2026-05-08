import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/screens/short_detail_screen.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/following/suggested_sellers_section.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/empty_shorts_view.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

import 'package:africaonlinestores/shared/components/cards/section_card.dart';

class ShortsFeedTab extends ConsumerStatefulWidget {
  final ShortsFeedType feedType;
  final String? contentMode;
  final String? categoryLabel;

  const ShortsFeedTab({
    super.key,
    required this.feedType,
    this.contentMode,
    this.categoryLabel,
  });

  @override
  ConsumerState<ShortsFeedTab> createState() => _ShortsFeedTabState();
}

class _ShortsFeedTabState extends ConsumerState<ShortsFeedTab> {
  final _scrollController = ScrollController();

  late final ShortsRepository _repository;

  final List<Short> _items = [];

  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;

  bool get _canLoadMore {
    return !_isLoading &&
        !_isLoadingMore &&
        _hasMore &&
        _nextCursor?.trim().isNotEmpty == true;
  }

  @override
  void initState() {
    super.initState();

    _repository = ShortsRepository(ref.read(shortsFeedApiProvider));

    _loadInitial();
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

    if (oldWidget.contentMode != widget.contentMode ||
        oldWidget.feedType != widget.feedType) {
      _loadInitial();
    }
  }

  Future<ShortsFeedPage> _fetchPage({String? cursor}) {
    switch (widget.feedType) {
      case ShortsFeedType.forYou:
        return _repository.fetchForYou(
          cursor: cursor,
          contentMode: widget.contentMode,
        );

      case ShortsFeedType.following:
        return _repository.fetchFollowing(
          cursor: cursor,
          contentMode: widget.contentMode,
        );

      case ShortsFeedType.live:
        return _repository.fetchForYou(
          cursor: cursor,
          contentMode: widget.contentMode,
        );
    }
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _nextCursor = null;
      _hasMore = true;
    });

    try {
      final page = await _fetchPage();

      if (!mounted) return;

      setState(() {
        _items
          ..clear()
          ..addAll(page.items);

        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _items.clear();
        _nextCursor = null;
        _hasMore = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_canLoadMore) return;

    final cursor = _nextCursor?.trim();

    if (cursor == null || cursor.isEmpty) return;

    setState(() => _isLoadingMore = true);

    try {
      final page = await _fetchPage(cursor: cursor);

      if (!mounted) return;

      setState(() {
        _items.addAll(page.items);
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!_canLoadMore) return;

    final extentAfter = _scrollController.position.extentAfter;

    if (extentAfter < 700) {
      _loadMore();
    }
  }

  void _openDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShortDetailScreen(
          initialShorts: List.from(_items),
          initialIndex: index,
          initialNextCursor: _nextCursor,
          initialHasMore: _hasMore,
        ),
      ),
    );
  }

  Widget _buildShortItem(BuildContext context, int index) {
    if (index >= _items.length) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final short = _items[index];

    return ShortCard(short: short, onTap: () => _openDetail(index));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isLoading && _items.isEmpty) {
      return EmptyShortsView(
        feedType: widget.feedType,
        categoryLabel: widget.categoryLabel,
        onRefresh: _loadInitial,
      );
    }

    if (widget.feedType == ShortsFeedType.following) {
      return ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          const SuggestedSellersSection(),

          const SizedBox(height: 22),

          SectionCard(
            title: 'Following Shorts',
            child: MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: _items.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: _buildShortItem,
            ),
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
