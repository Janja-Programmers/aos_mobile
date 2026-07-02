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
  final String? doctype;
  final String? name;
  final String? title;
  final String? subtitle;
  final String? image;
  final String? routeType;
  final String? routeId;

  const ActivityTarget({
    this.doctype,
    this.name,
    this.title,
    this.subtitle,
    this.image,
    this.routeType,
    this.routeId,
  });

  factory ActivityTarget.fromJson(Map<String, dynamic>? json) {
    return ActivityTarget(
      doctype: json?['doctype']?.toString(),
      name: json?['name']?.toString(),
      title: json?['title']?.toString(),
      subtitle: json?['subtitle']?.toString(),
      image: json?['image']?.toString(),
      routeType: json?['route_type']?.toString(),
      routeId: json?['route_id']?.toString(),
    );
  }
}

@immutable
class ActivityItem {
  final String id;
  final String group;
  final String type;
  final ActivityTarget target;
  final int count;
  final DateTime? occurredAt;
  final DateTime? lastOccurrenceAt;

  const ActivityItem({
    required this.id,
    required this.group,
    required this.type,
    required this.target,
    required this.count,
    this.occurredAt,
    this.lastOccurrenceAt,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final target = json['target'];
    return ActivityItem(
      id: json['id']?.toString() ?? json['name']?.toString() ?? '',
      group: json['activity_group']?.toString() ?? 'Other',
      type: json['activity_type']?.toString() ?? '',
      target: ActivityTarget.fromJson(asJsonMap(target)),
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      occurredAt: DateTime.tryParse(json['occurred_at']?.toString() ?? ''),
      lastOccurrenceAt: DateTime.tryParse(
        json['last_occurrence_at']?.toString() ?? '',
      ),
    );
  }
}

@immutable
class ActivityPage {
  final List<ActivityItem> items;
  final int total;
  final int start;
  final int limit;
  final bool hasMore;

  const ActivityPage({
    required this.items,
    required this.total,
    required this.start,
    required this.limit,
    required this.hasMore,
  });

  factory ActivityPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return ActivityPage(
      items: asJsonMapList(rawItems).map(ActivityItem.fromJson).toList(),
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      start: int.tryParse(json['start']?.toString() ?? '0') ?? 0,
      limit: int.tryParse(json['limit']?.toString() ?? '20') ?? 20,
      hasMore: json['has_more'] == true || json['has_more']?.toString() == '1',
    );
  }
}

final activityApiProvider = Provider<ActivityApi>((ref) {
  return ActivityApi(ref.read(apiClientProvider));
});

class ActivityApi {
  final ApiClient _client;

  const ActivityApi(this._client);

  Future<Either<Failure, ActivityPage>> listActivity({
    int start = 0,
    int limit = 20,
    String? group,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listActivity,
        queryParameters: {
          'start': start,
          'limit': limit,
          if (group != null && group != 'All') 'group': group,
        },
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final data = unwrapped.rightOrNull?['data'];
      if (data is! Map) {
        return Either.left(const Failure('Invalid activity response.'));
      }
      return Either.right(ActivityPage.fromJson(asJsonMap(data)));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load activity.'));
    }
  }

  Future<Either<Failure, void>> hideActivity(String activityId) async {
    try {
      final res = await _client.post(
        ApiEndpoints.hideActivity,
        data: {'activity_id': activityId},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to hide activity.'));
    }
  }

  Future<Either<Failure, void>> clearActivity({String? group}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.clearActivity,
        data: {if (group != null && group != 'All') 'group': group},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(null);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to clear activity.'));
    }
  }
}
