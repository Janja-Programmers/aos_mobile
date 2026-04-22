import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/providers/feed_search_provider.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/short_grid_card.dart';

class InspirationGrid extends ConsumerStatefulWidget {
  const InspirationGrid({super.key});

  @override
  ConsumerState<InspirationGrid> createState() => _InspirationGridState();
}

class _InspirationGridState extends ConsumerState<InspirationGrid> {
  final _scrollController = ScrollController();

  late final ProviderSubscription<String> _searchSub;

  String _currentQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shortGridControllerProvider.notifier).loadInitial();
    });

    _scrollController.addListener(_onScroll);

    /// ✅ SAFE manual listener
    _searchSub = ref.listenManual<String>(debouncedSearchProvider, (
      prev,
      next,
    ) {
      if (_currentQuery == next) return;

      _currentQuery = next;

      ref.read(shortGridControllerProvider.notifier).loadInitial(query: next);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 600) {
      ref
          .read(shortGridControllerProvider.notifier)
          .loadMore(query: _currentQuery);
    }
  }

  @override
  void dispose() {
    _searchSub.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortGridControllerProvider);

    if (state.isLoading && state.shorts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final validShorts = state.shorts.toList();

    if (validShorts.isEmpty) {
      return const Center(child: Text('No content found'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MasonryGridView.count(
        controller: _scrollController,

        crossAxisCount: 2,

        mainAxisSpacing: 10,
        crossAxisSpacing: 10,

        itemCount: validShorts.length + (state.hasMore ? 1 : 0),

        itemBuilder: (context, index) {
          if (index >= validShorts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final short = validShorts[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ShortGridCard(short: short, index: index),
          );
        },
      ),
    );
  }
}
