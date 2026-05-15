import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/inspiration_grid_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/following/inspiration_grid_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';

enum FeedTab { inspiration, following, saved }

enum FeedFilter { all, live, shorts }

/// Current selected tab
final feedTabProvider = StateProvider<FeedTab>((ref) => FeedTab.inspiration);

/// Current selected filter
final feedFilterProvider = StateProvider<FeedFilter>((ref) => FeedFilter.all);

final inspirationGridControllerProvider =
    StateNotifierProvider<InspirationGridController, InspirationGridState>((
      ref,
    ) {
      return InspirationGridController(
        ShortsRepository(ref.read(shortsFeedApiProvider)),
      );
    });
