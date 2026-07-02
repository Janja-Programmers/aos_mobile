import 'package:africaonlinestores/features/live/data/live_api.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
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

class LiveFeedPage extends Equatable {
  final List<LiveStream> items;
  final String? nextCursor;
  final bool hasMore;

  const LiveFeedPage({
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
  final LiveApi _liveApi;

  ShortsRepository(this._api, this._liveApi);

  /// FOR YOU FEED
  Future<ShortsFeedPage> fetchForYou({
    int limit = 10,
    String? cursor,
    String? contentMode,
  }) async {
    final result = await _api.fetchForYou(
      limit: limit,
      cursor: cursor,
      contentMode: contentMode,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (page) => ShortsFeedPage(
        items: page.items.map(ShortMapper.toDomain).toList(),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ),
    );
  }

  /// FOLLOWING FEED
  Future<ShortsFeedPage> fetchFollowing({
    int limit = 10,
    String? cursor,
    String? contentMode,
  }) async {
    final result = await _api.fetchFollowingGrid(
      limit: limit,
      cursor: cursor,
      contentMode: contentMode,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (page) => ShortsFeedPage(
        items: page.items.map(ShortMapper.toDomain).toList(),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ),
    );
  }

  /// LIVE FEED
  Future<LiveFeedPage> fetchLive({int limit = 20, String? cursor}) async {
    final start = int.tryParse(cursor ?? '') ?? 0;

    final result = await _liveApi.listLives(start: start, limit: limit);

    return result.fold((failure) => throw Exception(failure.message), (items) {
      final nextStart = start + items.length;
      final hasMore = items.length == limit;

      return LiveFeedPage(
        items: items,
        nextCursor: hasMore ? nextStart.toString() : null,
        hasMore: hasMore,
      );
    });
  }
}
