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
class SocialUserSummary {
  final String user;
  final String displayName;
  final String? avatar;
  final bool isVerified;
  final bool isLive;
  final String? liveId;
  final String followersDisplay;
  final bool iBlockedUser;
  final bool userBlockedMe;

  const SocialUserSummary({
    required this.user,
    required this.displayName,
    this.avatar,
    required this.isVerified,
    required this.isLive,
    this.liveId,
    required this.followersDisplay,
    required this.iBlockedUser,
    required this.userBlockedMe,
  });

  factory SocialUserSummary.fromJson(Map<String, dynamic> json) {
    return SocialUserSummary(
      user: json['user']?.toString() ?? json['blocked_user']?.toString() ?? '',
      displayName:
          json['full_name']?.toString() ??
          json['display_name']?.toString() ??
          json['user']?.toString() ??
          '',
      avatar: json['user_image']?.toString() ?? json['avatar']?.toString(),
      isVerified: _truthy(json['is_verified']),
      isLive: _truthy(json['is_live']),
      liveId: json['live_id']?.toString(),
      followersDisplay: json['total_followers_display']?.toString() ?? '',
      iBlockedUser: _truthy(json['i_blocked_user']),
      userBlockedMe: _truthy(json['user_blocked_me']),
    );
  }

  static bool _truthy(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value?.toString().toLowerCase() == 'true' ||
        value?.toString() == '1';
  }
}

@immutable
class SocialUserSearchPage {
  final List<SocialUserSummary> items;
  final int start;
  final int limit;
  final bool hasMore;

  const SocialUserSearchPage({
    required this.items,
    required this.start,
    required this.limit,
    required this.hasMore,
  });

  factory SocialUserSearchPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return SocialUserSearchPage(
      items: asJsonMapList(rawItems).map(SocialUserSummary.fromJson).toList(),
      start: int.tryParse(json['start']?.toString() ?? '0') ?? 0,
      limit: int.tryParse(json['limit']?.toString() ?? '20') ?? 20,
      hasMore: json['has_more'] == true || json['has_more']?.toString() == '1',
    );
  }
}

final socialSafetyApiProvider = Provider<SocialSafetyApi>((ref) {
  return SocialSafetyApi(ref.read(apiClientProvider));
});

class SocialSafetyApi {
  final ApiClient _client;

  const SocialSafetyApi(this._client);

  Future<Either<Failure, SocialUserSearchPage>> searchUsers({
    required String query,
    int start = 0,
    int limit = 20,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.searchUsers,
        queryParameters: {
          'query': query.trim(),
          'start': start,
          'limit': limit,
        },
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final data = unwrapped.rightOrNull?['data'];
      if (data is! Map) {
        return Either.left(const Failure('Invalid user search response.'));
      }
      return Either.right(SocialUserSearchPage.fromJson(asJsonMap(data)));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to search users.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> blockUser({
    required String targetUser,
    String? reason,
  }) async {
    return _postStatus(ApiEndpoints.blockUser, {
      'target_user': targetUser,
      'reason': reason?.trim() ?? '',
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> unblockUser({
    required String targetUser,
  }) async {
    return _postStatus(ApiEndpoints.unblockUser, {'target_user': targetUser});
  }

  Future<Either<Failure, List<SocialUserSummary>>> listBlockedUsers({
    int start = 0,
    int limit = 20,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.listBlockedUsers,
        queryParameters: {'start': start, 'limit': limit},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final data = asJsonMap(unwrapped.rightOrNull?['data']);
      return Either.right(
        asJsonMapList(data['items']).map(SocialUserSummary.fromJson).toList(),
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load blocked users.'));
    }
  }

  Future<Either<Failure, String>> reportUser({
    required String targetUser,
    required String reason,
    String? details,
    bool blockUser = false,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.reportUser,
        data: {
          'target_user': targetUser,
          'reason': reason,
          'details': details?.trim() ?? '',
          'block_user': blockUser ? 1 : 0,
        },
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(
        unwrapped.rightOrNull?['message']?.toString() ?? 'Report submitted.',
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to report user.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _postStatus(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _client.post(endpoint, data: data);
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final payload = unwrapped.rightOrNull?['data'];
      return Either.right(payload is Map ? asJsonMap(payload) : const {});
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update user status.'));
    }
  }
}
