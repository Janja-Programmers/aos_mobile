import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ActivityTarget {
  const ActivityTarget({
    this.doctype,
    this.name,
    this.title,
    this.subtitle,
    this.image,
    this.routeType,
    this.routeId,
  });

  final String? doctype;
  final String? name;
  final String? title;
  final String? subtitle;
  final String? image;
  final String? routeType;
  final String? routeId;

  factory ActivityTarget.fromJson(Map<String, dynamic>? json) {
    return ActivityTarget(
      doctype: _clean(json?['doctype']),
      name: _clean(json?['name']),
      title: _clean(json?['title']),
      subtitle: _clean(json?['subtitle']),
      image: _clean(json?['image']),
      routeType: _clean(json?['route_type']),
      routeId: _clean(json?['route_id']),
    );
  }
}

@immutable
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.group,
    required this.type,
    required this.target,
    required this.count,
    this.occurredAt,
    this.lastOccurrenceAt,
  });

  final String id;
  final String group;
  final String type;
  final ActivityTarget target;
  final int count;
  final DateTime? occurredAt;
  final DateTime? lastOccurrenceAt;

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: _clean(json['id']) ?? _clean(json['name']) ?? '',
      group: _clean(json['activity_group']) ?? 'Other',
      type: _clean(json['activity_type']) ?? '',
      target: ActivityTarget.fromJson(asJsonMap(json['target'])),
      count: asInt(json['count']),
      occurredAt: _parseDate(json['occurred_at']),
      lastOccurrenceAt: _parseDate(json['last_occurrence_at']),
    );
  }
}

@immutable
class ActivityPage {
  const ActivityPage({
    required this.items,
    required this.total,
    required this.start,
    required this.limit,
    required this.hasMore,
  });

  final List<ActivityItem> items;
  final int total;
  final int start;
  final int limit;
  final bool hasMore;

  factory ActivityPage.fromJson(Map<String, dynamic> json) {
    return ActivityPage(
      items: asJsonMapList(json['items'])
          .map(ActivityItem.fromJson)
          .where((ActivityItem item) => item.id.isNotEmpty)
          .toList(growable: false),
      total: asInt(json['total']),
      start: asInt(json['start']),
      limit: asInt(json['limit'], fallback: 20),
      hasMore: asBool(json['has_more']),
    );
  }
}

abstract interface class ActivityRepository {
  Future<Either<Failure, ActivityPage>> listActivity({
    int start = 0,
    int limit = 20,
    String? group,
    String? type,
  });

  Future<Either<Failure, String>> hideActivity(String activityId);

  Future<Either<Failure, int>> clearActivity({String? group, String? type});
}

final activityApiProvider = Provider<ActivityApi>((ref) {
  return ActivityApi(ref.read(apiClientProvider));
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ref.watch(activityApiProvider);
});

class ActivityApi implements ActivityRepository {
  const ActivityApi(this._client);

  final ApiClient _client;

  @override
  Future<Either<Failure, ActivityPage>> listActivity({
    int start = 0,
    int limit = 20,
    String? group,
    String? type,
  }) async {
    try {
      final Response<Map<String, dynamic>> res = await _client.get(
        ApiEndpoints.listActivity,
        queryParameters: <String, dynamic>{
          'start': start,
          'limit': limit,
          if (_clean(group) != null && group != 'All') 'group': group!.trim(),
          if (_clean(type) != null) 'type': type!.trim(),
        },
      );
      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);

      final Map<String, dynamic> envelope = asJsonMap(result.rightOrNull);
      final Map<String, dynamic> data = asJsonMap(envelope['data']);
      if (data.isEmpty && envelope['data'] == null) {
        return Either.left(const Failure('Invalid activity response.'));
      }
      return Either.right(ActivityPage.fromJson(data));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load activity.'));
    }
  }

  @override
  Future<Either<Failure, String>> hideActivity(String activityId) async {
    final String id = activityId.trim();
    if (id.isEmpty) return Either.left(const Failure('Invalid activity.'));
    try {
      final Response<Map<String, dynamic>> res = await _client.post(
        ApiEndpoints.hideActivity,
        data: <String, dynamic>{'activity_id': id},
      );
      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);
      final Map<String, dynamic> envelope = asJsonMap(result.rightOrNull);
      final Map<String, dynamic> data = asJsonMap(envelope['data']);
      return Either.right(_clean(data['id']) ?? id);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to hide activity.'));
    }
  }

  @override
  Future<Either<Failure, int>> clearActivity({
    String? group,
    String? type,
  }) async {
    try {
      final Response<Map<String, dynamic>> res = await _client.post(
        ApiEndpoints.clearActivity,
        data: <String, dynamic>{
          if (_clean(group) != null && group != 'All') 'group': group!.trim(),
          if (_clean(type) != null) 'type': type!.trim(),
        },
      );
      final result = unwrapFrappe(res);
      if (result.isLeft) return Either.left(result.leftOrNull!);
      final Map<String, dynamic> envelope = asJsonMap(result.rightOrNull);
      final Map<String, dynamic> data = asJsonMap(envelope['data']);
      return Either.right(asInt(data['cleared_count']));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to clear activity.'));
    }
  }
}

String? _clean(Object? value) {
  final String? text = value?.toString().trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

DateTime? _parseDate(Object? value) {
  final String? text = _clean(value);
  return text == null ? null : DateTime.tryParse(text);
}
