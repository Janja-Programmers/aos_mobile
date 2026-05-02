import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

import 'package:equatable/equatable.dart';

class ShortsFeedPage extends Equatable {
  final List<Short> items;
  final String? nextCursor;
  final bool hasMore;

  const ShortsFeedPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items, nextCursor, hasMore];
}

class ShortsRepository {
  final ShortsFeedApi _api;

  ShortsRepository(this._api);

  /// FOR YOU FEED
  Future<ShortsFeedPage> fetchForYou({int limit = 10, String? cursor}) async {
    final result = await _api.fetchForYou(limit: limit, cursor: cursor);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (page) => ShortsFeedPage(
        items: page.items.map((model) => ShortMapper.toDomain(model)).toList(),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ),
    );
  }

  /// FOLLOWING FEED
  Future<ShortsFeedPage> fetchFollowing({
    int limit = 10,
    String? cursor,
  }) async {
    final result = await _api.fetchFollowingGrid(limit: limit, cursor: cursor);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (page) => ShortsFeedPage(
        items: page.items.map((model) => ShortMapper.toDomain(model)).toList(),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ),
    );
  }
}
