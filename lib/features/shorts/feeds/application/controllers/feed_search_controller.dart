import 'dart:async';

import 'package:africaonlinestores/features/shorts/feeds/application/providers/feed_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedSearchController {
  Timer? _debounce;

  void onQueryChanged(WidgetRef ref, String query) {
    ref.read(feedSearchQueryProvider.notifier).state = query;

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 450), () {
      ref.read(debouncedSearchProvider.notifier).state = query;
    });
  }

  void dispose() {
    _debounce?.cancel();
  }
}

final feedSearchControllerProvider = Provider<FeedSearchController>((ref) {
  final controller = FeedSearchController();

  ref.onDispose(controller.dispose);

  return controller;
});
