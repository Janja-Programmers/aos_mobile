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
    final totals = asJsonMap(json['totals']);
    final values = totals.isEmpty ? json : totals;
    return ShortsTopItem(
      id: json['id']?.toString() ?? json['short']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      views: _toInt(values['views'] ?? json['views']),
      likes: _toInt(values['likes'] ?? json['likes']),
      shares: _toInt(values['shares'] ?? json['shares']),
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
    return ShortsAnalyticsResult(
      dateFrom: DateTime.tryParse(json['date_from']?.toString() ?? ''),
      dateTo: DateTime.tryParse(json['date_to']?.toString() ?? ''),
      totals: ShortsAnalyticsSummary.fromJson(asJsonMap(json['totals'])),
      daily: asJsonMapList(json['daily']),
      topShorts: asJsonMapList(
        json['top_shorts'],
      ).map(ShortsTopItem.fromJson).toList(growable: false),
      overview: asJsonMap(json['overview']),
    );
  }
}

class ShortAnalyticsResult {
  const ShortAnalyticsResult({
    required this.short,
    required this.dateFrom,
    required this.dateTo,
    required this.totals,
    required this.currentTotals,
    required this.daily,
  });

  final Map<String, dynamic> short;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ShortsAnalyticsSummary totals;
  final ShortsAnalyticsSummary currentTotals;
  final List<Map<String, dynamic>> daily;

  factory ShortAnalyticsResult.fromJson(Map<String, dynamic> json) {
    return ShortAnalyticsResult(
      short: asJsonMap(json['short']),
      dateFrom: DateTime.tryParse(json['date_from']?.toString() ?? ''),
      dateTo: DateTime.tryParse(json['date_to']?.toString() ?? ''),
      totals: ShortsAnalyticsSummary.fromJson(asJsonMap(json['totals'])),
      currentTotals: ShortsAnalyticsSummary.fromJson(
        asJsonMap(json['current_totals']),
      ),
      daily: asJsonMapList(json['daily']),
    );
  }
}
