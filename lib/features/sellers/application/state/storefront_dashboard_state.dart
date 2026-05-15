import 'package:africaonlinestores/features/sellers/domain/storefront_analytics.dart';
import 'package:africaonlinestores/features/sellers/domain/storefront_post.dart';

class StorefrontDashboardState {
  final bool loading;
  final String? error;
  final List<StorefrontPost> posts;
  final StorefrontAnalytics analytics;

  const StorefrontDashboardState({
    required this.loading,
    required this.error,
    required this.posts,
    required this.analytics,
  });

  factory StorefrontDashboardState.initial() {
    return StorefrontDashboardState(
      loading: false,
      error: null,
      posts: const [],
      analytics: StorefrontAnalytics.empty(),
    );
  }

  StorefrontDashboardState copyWith({
    bool? loading,
    String? error,
    List<StorefrontPost>? posts,
    StorefrontAnalytics? analytics,
  }) {
    return StorefrontDashboardState(
      loading: loading ?? this.loading,
      error: error,
      posts: posts ?? this.posts,
      analytics: analytics ?? this.analytics,
    );
  }
}
