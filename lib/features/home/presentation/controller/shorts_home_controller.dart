import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

final shortsHomeControllerProvider =
    AsyncNotifierProvider<ShortsHomeController, List<Short>>(
      ShortsHomeController.new,
    );

class ShortsHomeController extends AsyncNotifier<List<Short>> {
  late final ShortsRepository _repository;

  @override
  Future<List<Short>> build() async {
    _repository = ShortsRepository(ref.read(shortsFeedApiProvider));

    return _load();
  }

  Future<List<Short>> _load() async {
    final page = await _repository.fetchForYou();
    return page.items;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final items = await _load();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
