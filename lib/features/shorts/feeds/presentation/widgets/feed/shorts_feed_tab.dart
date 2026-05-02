import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/following/suggested_sellers_section.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/screens/short_detail_screen.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_card.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortsFeedTab extends ConsumerStatefulWidget {
  final ShortsFeedType feedType;

  const ShortsFeedTab({super.key, required this.feedType});

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

  @override
  void initState() {
    super.initState();

    _repository = ShortsRepository(ref.read(shortsFeedApiProvider));

    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<ShortsFeedPage> _fetchPage({String? cursor}) {
    switch (widget.feedType) {
      case ShortsFeedType.forYou:
        return _repository.fetchForYou(cursor: cursor);
      case ShortsFeedType.following:
        return _repository.fetchFollowing(cursor: cursor);
    }
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);

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
      debugPrint('Error loading ${widget.feedType.label}: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final page = await _fetchPage(cursor: _nextCursor);

      if (!mounted) return;

      setState(() {
        _items.addAll(page.items);
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      debugPrint('Error loading more ${widget.feedType.label}: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 600;

    if (isNearBottom) {
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
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
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
      return RefreshIndicator(
        onRefresh: _loadInitial,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 160),
            Center(
              child: Text(
                'No shorts in ${widget.feedType.label}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.feedType == ShortsFeedType.following) {
      return RefreshIndicator(
        onRefresh: _loadInitial,
        child: ListView(
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
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: MasonryGridView.count(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: _buildShortItem,
      ),
    );
  }
}
