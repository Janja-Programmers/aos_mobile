import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Feed cards route canonical items to their existing detail flows', () {
    final feed = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/shorts_feed_tab.dart',
    ).readAsStringSync();
    final liveRoutes = File(
      'lib/features/live/navigation/live_routes.dart',
    ).readAsStringSync();

    expect(feed, contains('ShortsNavigation.toShortDetail('));
    expect(
      feed,
      contains('LiveNavigation.toLiveRoom(context, liveId: item.id)'),
    );
    expect(feed, isNot(contains('joinLive(')));
    expect(feed, isNot(contains('trackJoin(')));
    expect(feed, isNot(contains('LiveKitService')));

    expect(liveRoutes, contains("queryParameters: {'live_id': liveId}"));
    expect(liveRoutes, contains('LiveScreen(liveId: liveId)'));
  });

  test('Live discovery keeps list browsing separate from room presence', () {
    final feed = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/shorts_feed_tab.dart',
    ).readAsStringSync();
    final repository = File(
      'lib/features/shorts/feeds/repository/short_feed_repository.dart',
    ).readAsStringSync();

    expect(feed, contains('ShortsFeedType.live'));
    expect(feed, contains('_repository.fetchLive(cursor: cursor)'));
    expect(
      repository,
      contains('_liveApi.listLives(limit: limit, cursor: cursor)'),
    );
    expect(repository, isNot(contains('joinLive(')));
  });

  test('Feed and Live list UI use authoritative card fields', () {
    final shortCard = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/short_card.dart',
    ).readAsStringSync();
    final liveCard = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/live_card.dart',
    ).readAsStringSync();
    final feed = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/shorts_feed_tab.dart',
    ).readAsStringSync();

    expect(shortCard, contains('short.durationSeconds'));
    expect(shortCard, contains('short.metrics.likeCount'));
    expect(shortCard, contains('short.thumbnailUrl'));
    expect(shortCard, contains('ShortContentModes.shop'));
    expect(shortCard, contains('ShortContentModes.geo'));
    expect(shortCard, contains('ShortContentModes.vibes'));
    expect(shortCard, contains('ShortContentModes.learn'));
    expect(shortCard, contains('_ContentModeBadge.fromShort(short)'));
    expect(shortCard, contains('feedGeoBadge'));
    expect(shortCard, contains('feedVibesBadge'));
    expect(shortCard, contains('feedLearnBadge'));
    expect(liveCard, contains('live.viewerCount'));
    expect(liveCard, contains('live.thumbnail'));
    expect(liveCard, contains('live.coverImage'));
    expect(feed, contains('feedLiveNow'));
    expect(feed, contains('feedRefreshLives'));
    expect(feed, contains('crossAxisCount: 2'));
    expect(feed, contains('RefreshIndicator('));
  });

  test('Feed category labels and selected colors preserve canonical UX', () {
    final chips = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/feed_category_chips.dart',
    ).readAsStringSync();
    final l10n = File(
      'lib/features/shorts/feeds/presentation/feed_l10n.dart',
    ).readAsStringSync();

    expect(chips, contains("'geo' => l10n.feedCategoryGeo"));
    expect(chips, contains("'vibes' => l10n.feedCategoryVibes"));
    expect(chips, contains("'geo' => Colors.green"));
    expect(chips, contains("'vibes' => Colors.purple"));
    expect(chips, contains("'learn' => Colors.blue"));
    expect(l10n, contains("en: 'Geo'"));
    expect(l10n, contains("en: 'Vibes'"));
    expect(l10n, isNot(contains("en: 'Geography'")));
    expect(l10n, isNot(contains("en: 'Fun'")));
  });

  test('Feed empty states are localized and do not compare display labels', () {
    final empty = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/empty_shorts_view.dart',
    ).readAsStringSync();

    expect(empty, contains('feedNoCategoryShortsTitle'));
    expect(empty, contains('feedNoLivesTitle'));
    expect(empty, contains('feedRefresh'));
    expect(empty, contains('hasCategoryFilter'));
    expect(empty, isNot(contains("category != 'All'")));
    expect(empty, isNot(contains("const Text('Refresh')")));
  });

  test('Changed list surfaces preserve accessibility and RTL-aware layout', () {
    final screen = File(
      'lib/features/shorts/feeds/presentation/screens/short_list_screen.dart',
    ).readAsStringSync();
    final chips = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/feed_category_chips.dart',
    ).readAsStringSync();
    final shortCard = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/short_card.dart',
    ).readAsStringSync();
    final liveCard = File(
      'lib/features/shorts/feeds/presentation/widgets/feed/live_card.dart',
    ).readAsStringSync();

    expect(screen, contains('PositionedDirectional('));
    expect(chips, contains('selected: isSelected'));
    expect(chips, contains('MediaQuery.textScalerOf(context)'));
    expect(shortCard, contains('Semantics('));
    expect(shortCard, contains('PositionedDirectional('));
    expect(liveCard, contains('Semantics('));
    expect(liveCard, contains('PositionedDirectional('));
  });
}
