import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/replies_state.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/replies_controller.dart';

enum FeedTab { inspiration, following, saved }

enum FeedFilter { all, live, photos, shorts }

/// Current selected tab
final feedTabProvider = StateProvider<FeedTab>((ref) => FeedTab.inspiration);

/// Current selected filter
final feedFilterProvider = StateProvider<FeedFilter>((ref) => FeedFilter.all);

final repliesControllerProvider =
    StateNotifierProvider.family<RepliesController, RepliesState, String>((
      ref,
      rootCommentId,
    ) {
      return RepliesController(
        ref.read(shortsCommentsApiProvider),
        rootCommentId,
      );
    });
