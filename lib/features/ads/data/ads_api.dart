import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';

class AdsApi {
  AdsApi(this._client);
  final ApiClient _client;

  Dio get _dio => _client.dio;

  static const _allowedSorts = {
    'rating_high',
    'price_low',
    'price_high',
    'recent',
  };

  static const _allowedPromotionTypes = {'offer', 'deal', 'flash_sale'};

  static const _allowedPriceTypes = {
    'Fixed',
    'Negotiable',
    'Contact for price',
    'Free',
  };

  Future<Either<Failure, List<Map<String, dynamic>>>> getLocations() async {
    try {
      final res = await _client.get(
        ApiEndpoints.getLocationsEndpoint,
        marketContext: true,
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) {
        return Either.left(unwrapped.leftOrNull!);
      }

      final payload = unwrapped.rightOrNull!;

      final raw = payload['data'];

      if (raw is List) {
        return Either.right(
          raw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }

      if (raw is Map) {
        final list =
            raw['locations'] ?? raw['items'] ?? raw['data'] ?? raw['list'];

        if (list is List) {
          return Either.right(
            list
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
          );
        }
      }

      return Either.right(const []);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load locations.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getCategorySchema({
    required String categoryId,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.getCategorySchemaEndpoint,
        queryParameters: {'category': categoryId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load category schema.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> createAd({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.createAdEndpoint, data: payload);
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to create ad.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> updateAd({
    required String adId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.updateAdEndpoint,
        data: {'ad_id': adId, ...payload},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update draft.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> upsertAdDraft({
    required String draftId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.upsertAdDraftEndpoint,
        data: {'draft_id': draftId, 'payload': payload},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update draft.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> submitAdDraft({
    required String draftId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.submitAdDraftEndpoint,
        queryParameters: {'draft_id': draftId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to submit draft.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> saveAdDraft({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.upsertAdDraftEndpoint,
        data: {'payload': payload},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to save draft.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> setAdStatus({
    required String adId,
    required String action,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.setAdStatusEndpoint,
        queryParameters: {'ad_id': adId, "action": action},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to save draft.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> listAds({
    String? locationId,
    String? categoryId,
    String? sellerId,
    String? q,
    String? sort,
    String? priceType,
    String? promotionType,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (sort != null && !_allowedSorts.contains(sort)) {
        return Either.left(Failure('Invalid sort value: $sort'));
      }

      if (promotionType != null &&
          !_allowedPromotionTypes.contains(promotionType)) {
        return Either.left(Failure('Invalid promotion type: $promotionType'));
      }

      if (priceType != null && !_allowedPriceTypes.contains(priceType)) {
        return Either.left(Failure('Invalid price type: $priceType'));
      }

      final queryParams = <String, dynamic>{
        if (locationId != null) 'location': locationId.trim(),
        if (categoryId?.trim().isNotEmpty == true)
          'category': categoryId!.trim(),
        if (sellerId?.trim().isNotEmpty == true) 'seller': sellerId!.trim(),
        if (q?.trim().isNotEmpty == true) 'q': q!.trim(),
        if (sort?.trim().isNotEmpty == true) 'sort': sort!.trim(),
        if (priceType?.trim().isNotEmpty == true)
          'price_type': priceType!.trim(),
        if (promotionType?.trim().isNotEmpty == true)
          'promotion_type': promotionType!.trim(),

        'price_min': ?priceMin,
        'price_max': ?priceMax,
        'rating_min': ?ratingMin,

        'limit': limit,
        'offset': offset,
      };

      final res = await _client.get(
        ApiEndpoints.listAdsEndpoint,
        marketContext: true,
        queryParameters: queryParams,
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch ads.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> listAdDrafts({
    String? locationId,
    String? categoryId,
    String? q,
    String? sort,
    String? promotionType,
    String? priceType,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (sort != null && !_allowedSorts.contains(sort)) {
        return Either.left(Failure('Invalid sort value: $sort'));
      }

      if (promotionType != null &&
          !_allowedPromotionTypes.contains(promotionType)) {
        return Either.left(Failure('Invalid promotion type: $promotionType'));
      }

      if (priceType != null && !_allowedPriceTypes.contains(priceType)) {
        return Either.left(Failure('Invalid price type: $priceType'));
      }

      final queryParams = <String, dynamic>{
        if (locationId?.trim().isNotEmpty == true)
          'location': locationId!.trim(),
        if (categoryId?.trim().isNotEmpty == true)
          'category': categoryId!.trim(),
        if (q?.trim().isNotEmpty == true) 'q': q!.trim(),
        if (sort?.trim().isNotEmpty == true) 'sort': sort!.trim(),
        if (promotionType?.trim().isNotEmpty == true)
          'promotion_type': promotionType!.trim(),
        if (priceType?.trim().isNotEmpty == true)
          'price_type': priceType!.trim(),

        'price_min': ?priceMin,

        'price_max': ?priceMax,

        'rating_min': ?ratingMin,

        'limit': limit,
        'offset': offset,
      };

      final res = await _client.get(
        ApiEndpoints.listAdDraftsEndpoint,
        marketContext: true,
        queryParameters: queryParams,
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch ads.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> myAds({
    AdBackendStatus status = AdBackendStatus.active,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.myAdsEndpoint,
        queryParameters: {
          'status': status.value,
          'limit': limit,
          'offset': offset,
        },
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch your ads.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getAd({
    required String adId,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.getAdEndpoint,
        queryParameters: {'ad_id': adId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch ad details.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getMyAd({
    required String adId,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.getMyAdEndpoint,
        queryParameters: {'ad_id': adId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch ad details.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getAdDraft({
    required String draftId,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.getAdDraftEndpoint,
        queryParameters: {'draft_id': draftId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch ad details.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> abandonAdDraft({
    required String draftId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.abandonAdDraftEndpoint,
        data: {'draft_id': draftId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to abandon draft.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> listWishlist({
    int limit = 200,
    int offset = 0,
    String? sort,
    String? q,
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool? verifiedSellers,
    bool? preferredStore,
  }) async {
    try {
      if (sort != null && !_allowedSorts.contains(sort)) {
        return Either.left(Failure('Invalid sort value: $sort'));
      }

      final cleanQuery = q?.trim();
      final res = await _dio.get(
        ApiEndpoints.listWishlistEndpoint,
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (sort?.trim().isNotEmpty == true) 'sort': sort!.trim(),
          if (cleanQuery?.isNotEmpty == true) ...{
            'q': cleanQuery,
            'search': cleanQuery,
          },
          'price_min': ?priceMin,
          'price_max': ?priceMax,
          'rating_min': ?ratingMin,
          if (verifiedSellers != null)
            'verified_sellers': verifiedSellers ? 1 : 0,
          if (preferredStore != null) 'preferred_store': preferredStore ? 1 : 0,
        },
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch wishlist.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> toggleWishlist({
    required String adId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.toggleWishlistEndpoint,
        data: {'ad_id': adId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update wishlist.'));
    }
  }
}
