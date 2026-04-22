import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

final shortsHomeControllerProvider =
    AsyncNotifierProvider<ShortsHomeController, List<Short>>(
      ShortsHomeController.new,
    );

class ShortsHomeController extends AsyncNotifier<List<Short>> {
  late final ShortsFeedApi _api;

  @override
  Future<List<Short>> build() async {
    _api = ref.read(shortsFeedApiProvider);

    return _load();
  }

  Future<List<Short>> _load() async {
    final res = await _api.fetchForYou();
    return res.fold((_) => const [], (page) => page.items);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    final items = await _load();

    state = AsyncData(items);
  }
}
