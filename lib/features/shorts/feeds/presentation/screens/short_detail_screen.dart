import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/video/short_video_page.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortDetailScreen extends ConsumerStatefulWidget {
  final List<Short> initialShorts;
  final int initialIndex;
  final String? initialNextCursor;
  final bool initialHasMore;

  const ShortDetailScreen({
    super.key,
    required this.initialShorts,
    required this.initialIndex,
    required this.initialNextCursor,
    required this.initialHasMore,
  });

  @override
  ConsumerState<ShortDetailScreen> createState() => _ShortDetailScreenState();
}

class _ShortDetailScreenState extends ConsumerState<ShortDetailScreen> {
  static const int _loadMoreThreshold = 2;
  static const int _prepareRadius = 1;

  late final PageController _pageController;
  late final ShortsRepository _repository;

  late List<Short> _items;
  late String? _nextCursor;
  late bool _hasMore;

  bool _isLoadingMore = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _repository = ShortsRepository(ref.read(shortsFeedApiProvider));

    _items = List<Short>.from(widget.initialShorts);
    _nextCursor = widget.initialNextCursor;
    _hasMore = widget.initialHasMore;
    _currentIndex = widget.initialIndex;

    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final page = await _repository.fetchForYou(
        limit: 10,
        cursor: _nextCursor,
      );

      if (!mounted) return;

      setState(() {
        _items.addAll(page.items);
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } catch (e) {
      debugPrint('Error loading more shorts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    if (index >= _items.length - _loadMoreThreshold) {
      _loadMore();
    }
  }

  bool _shouldPrepareVideo(int index) {
    return (index - _currentIndex).abs() <= _prepareRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _items.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final short = _items[index];

          return ShortVideoPage(
            key: ValueKey(short.id.value),
            short: short,
            isActive: index == _currentIndex,
            shouldPrepare: _shouldPrepareVideo(index),
          );
        },
      ),
    );
  }
}
