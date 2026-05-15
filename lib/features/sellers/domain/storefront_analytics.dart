import 'package:africaonlinestores/features/sellers/domain/storefront_post.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class StorefrontAnalytics {
  final int totalViews;
  final int totalLikes;
  final int totalComments;
  final int totalImpressions;
  final List<StorefrontPost> topPosts;

  const StorefrontAnalytics({
    required this.totalViews,
    required this.totalLikes,
    required this.totalComments,
    required this.totalImpressions,
    required this.topPosts,
  });

  factory StorefrontAnalytics.empty() {
    return const StorefrontAnalytics(
      totalViews: 0,
      totalLikes: 0,
      totalComments: 0,
      totalImpressions: 0,
      topPosts: [],
    );
  }

  factory StorefrontAnalytics.fromShorts(List<Short> shorts) {
    final sorted = [...shorts];

    sorted.sort((a, b) {
      final aScore =
          a.metrics.viewCount + a.metrics.likeCount + a.metrics.commentCount;
      final bScore =
          b.metrics.viewCount + b.metrics.likeCount + b.metrics.commentCount;

      return bScore.compareTo(aScore);
    });

    return StorefrontAnalytics(
      totalViews: shorts.fold(0, (sum, item) => sum + item.metrics.viewCount),
      totalLikes: shorts.fold(0, (sum, item) => sum + item.metrics.likeCount),
      totalComments: shorts.fold(
        0,
        (sum, item) => sum + item.metrics.commentCount,
      ),
      totalImpressions: shorts.fold(
        0,
        (sum, item) => sum + item.metrics.impressionCount,
      ),
      topPosts: sorted.take(5).map(StorefrontPost.fromShort).toList(),
    );
  }
}
