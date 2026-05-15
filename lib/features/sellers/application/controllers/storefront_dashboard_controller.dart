import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/sellers/application/state/storefront_dashboard_state.dart';
import 'package:africaonlinestores/features/sellers/domain/storefront_analytics.dart';
import 'package:africaonlinestores/features/sellers/domain/storefront_post.dart';

import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';

class StorefrontDashboardController
    extends StateNotifier<StorefrontDashboardState> {
  final ShortsManagementApi _shortsManagementApi;

  StorefrontDashboardController({
    required ShortsManagementApi shortsManagementApi,
  }) : _shortsManagementApi = shortsManagementApi,
       super(StorefrontDashboardState.initial()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final res = await _shortsManagementApi.myShorts();

      res.fold(
        (failure) {
          state = state.copyWith(loading: false, error: failure.message);
        },
        (shorts) {
          final posts = shorts.map(StorefrontPost.fromShort).toList();

          state = state.copyWith(
            loading: false,
            error: null,
            posts: posts,
            analytics: StorefrontAnalytics.fromShorts(shorts),
          );
        },
      );
    } catch (e) {
      debugPrint(' storefront dashboard load failed: $e');

      state = state.copyWith(
        loading: false,
        error: 'Failed to load storefront posts.',
      );
    }
  }

  Future<String?> deletePost(String shortId) async {
    final previousPosts = state.posts;

    state = state.copyWith(
      posts: previousPosts.where((post) => post.id != shortId).toList(),
      analytics: StorefrontAnalytics.fromShorts(
        previousPosts
            .where((post) => post.id != shortId)
            .map((post) => post.short)
            .toList(),
      ),
    );

    final res = await _shortsManagementApi.deleteShort(shortId: shortId);

    return res.fold((failure) {
      state = state.copyWith(
        posts: previousPosts,
        analytics: StorefrontAnalytics.fromShorts(
          previousPosts.map((post) => post.short).toList(),
        ),
        error: failure.message,
      );

      return failure.message;
    }, (_) => null);
  }
}
