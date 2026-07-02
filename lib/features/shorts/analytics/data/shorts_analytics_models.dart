import 'package:africaonlinestores/core/utils/json_utils.dart';

class ShortsAnalyticsSummary {
  final int impressions;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final int downloads;
  final int reposts;
  final int engagements;
  final int watchTimeMs;
  final double avgWatchTimeMs;
  final double completionRate;
  final double engagementRate;

  const ShortsAnalyticsSummary({
    required this.impressions,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saves,
    required this.downloads,
    required this.reposts,
    required this.engagements,
    required this.watchTimeMs,
    required this.avgWatchTimeMs,
    required this.completionRate,
    required this.engagementRate,
  });

  factory ShortsAnalyticsSummary.empty() {
    return const ShortsAnalyticsSummary(
      impressions: 0,
      views: 0,
      likes: 0,
      comments: 0,
      shares: 0,
      saves: 0,
      downloads: 0,
      reposts: 0,
      engagements: 0,
      watchTimeMs: 0,
      avgWatchTimeMs: 0,
      completionRate: 0,
      engagementRate: 0,
    );
  }

  factory ShortsAnalyticsSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ShortsAnalyticsSummary.empty();

    return ShortsAnalyticsSummary(
      impressions: _toInt(json['impressions']),
      views: _toInt(json['views']),
      likes: _toInt(json['likes']),
      comments: _toInt(json['comments']),
      shares: _toInt(json['shares']),
      saves: _toInt(json['saves']),
      downloads: _toInt(json['downloads']),
      reposts: _toInt(json['reposts']),
      engagements: _toInt(json['engagements']),
      watchTimeMs: _toInt(json['watch_time_ms']),
      avgWatchTimeMs: _toDouble(json['avg_watch_time_ms']),
      completionRate: _toDouble(json['completion_rate']),
      engagementRate: _toDouble(json['engagement_rate']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ShortsTopItem {
  final String id;
  final String caption;
  final String? thumbnailUrl;
  final int views;
  final int likes;
  final int shares;

  const ShortsTopItem({
    required this.id,
    required this.caption,
    this.thumbnailUrl,
    required this.views,
    required this.likes,
    required this.shares,
  });

  factory ShortsTopItem.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] is Map<String, dynamic>
        ? json['totals'] as Map<String, dynamic>
        : json;

    return ShortsTopItem(
      id: json['id']?.toString() ?? json['short']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      views: _toInt(totals['views'] ?? json['views']),
      likes: _toInt(totals['likes'] ?? json['likes']),
      shares: _toInt(totals['shares'] ?? json['shares']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ShortsAnalyticsResult {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ShortsAnalyticsSummary totals;
  final List<Map<String, dynamic>> daily;
  final List<ShortsTopItem> topShorts;
  final Map<String, dynamic> overview;

  const ShortsAnalyticsResult({
    required this.dateFrom,
    required this.dateTo,
    required this.totals,
    required this.daily,
    required this.topShorts,
    required this.overview,
  });

  factory ShortsAnalyticsResult.fromJson(Map<String, dynamic> json) {
    final topShorts = asJsonMapList(
      json['top_shorts'],
    ).map(ShortsTopItem.fromJson).toList(growable: false);

    return ShortsAnalyticsResult(
      dateFrom: DateTime.tryParse(json['date_from']?.toString() ?? ''),
      dateTo: DateTime.tryParse(json['date_to']?.toString() ?? ''),
      totals: ShortsAnalyticsSummary.fromJson(asJsonMap(json['totals'])),
      daily: asJsonMapList(json['daily']),
      topShorts: topShorts,
      overview: asJsonMap(json['overview']),
    );
  }
}
