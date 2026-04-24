import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/failure.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/models/short_feed_page.dart';

final shortsRepositoryProvider = Provider<ShortsRepository>((ref) {
  return ShortsRepositoryImpl(ref.read(shortsFeedApiProvider));
});

abstract class ShortsRepository {
  Future<ShortFeedPage> fetchForYou({String? cursor});
}

class ShortsRepositoryImpl implements ShortsRepository {
  final ShortsFeedApi api;

  ShortsRepositoryImpl(this.api);

  @override
  Future<ShortFeedPage> fetchForYou({String? cursor}) async {
    final result = await api.fetchForYou(cursor: cursor);

    return result.fold(
      (failure) {
        throw Failure(failure.message);
      },
      (page) {
        return page;
      },
    );
  }
}
