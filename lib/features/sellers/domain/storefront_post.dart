import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class StorefrontPost {
  final String id;
  final String title;
  final String age;
  final String views;
  final String likes;
  final String comments;
  final String duration;
  final String? imageUrl;
  final bool isLive;
  final Short short;

  const StorefrontPost({
    required this.id,
    required this.title,
    required this.age,
    required this.views,
    required this.likes,
    required this.comments,
    required this.duration,
    required this.short,
    this.imageUrl,
    this.isLive = false,
  });

  factory StorefrontPost.fromShort(Short short) {
    return StorefrontPost(
      id: short.id.value,
      title: short.caption.value.isEmpty
          ? 'Untitled short'
          : short.caption.value,
      age: _formatAge(short.postedAt),
      views: _formatCount(short.metrics.viewCount),
      likes: _formatCount(short.metrics.likeCount),
      comments: _formatCount(short.metrics.commentCount),
      duration: _formatDuration(short.durationSeconds),
      imageUrl: short.thumbnailUrl,
      short: short,
    );
  }

  static String _formatDuration(double seconds) {
    final total = seconds.round();
    final minutes = total ~/ 60;
    final secs = total % 60;

    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String _formatAge(DateTime? postedAt) {
    if (postedAt == null) return '';

    final diff = DateTime.now().difference(postedAt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final weeks = diff.inDays ~/ 7;
    if (weeks < 4) return '${weeks}w ago';

    final months = diff.inDays ~/ 30;
    return '${months}mo ago';
  }

  static String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}
