import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/ads_form/domain/ad_location_page.dart';
import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:dio/dio.dart';

class AdsApi implements AdLocationRepository {
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

  @override
  Future<Either<Failure, AdLocationPage>> getLocations({
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final String cleanQuery = query?.trim() ?? '';
      final res = await _client.get(
        ApiEndpoints.getLocationsEndpoint,
        marketContext: true,
        queryParameters: <String, dynamic>{
          if (cleanQuery.isNotEmpty) 'q': cleanQuery,
          'limit': limit,
          'offset': offset,
        },
      );

      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) {
        return Either.left(unwrapped.leftOrNull!);
      }

      final payload = unwrapped.rightOrNull!;
      final data = asJsonMap(payload['data']);
      final locations = asJsonMapList(data['locations'])
          .map(AdLocation.fromJson)
          .where(
            (AdLocation item) => item.id.isNotEmpty && item.name.isNotEmpty,
          )
          .toList(growable: false);
      final pagination = asJsonMap(data['pagination']);

      return Either.right(
        AdLocationPage(
          items: locations,
          limit: asInt(pagination['limit'], fallback: limit),
          offset: asInt(pagination['offset'], fallback: offset),
          hasMore: asBool(pagination['has_more']),
          nextOffset: asNullableInt(pagination['next_offset']),
        ),
      );
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
      final res = await _dio.get<Map<String, dynamic>>(
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
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.createAdEndpoint,
        data: payload,
      );
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
      final res = await _dio.post<Map<String, dynamic>>(
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
      final res = await _dio.post<Map<String, dynamic>>(
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
      final res = await _dio.post<Map<String, dynamic>>(
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
      final res = await _dio.post<Map<String, dynamic>>(
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
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.setAdStatusEndpoint,
        queryParameters: {'ad_id': adId, 'action': action},
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
        if (categoryId?.trim().isNotEmpty ?? false)
          'category': categoryId!.trim(),
        if (sellerId?.trim().isNotEmpty ?? false) 'seller': sellerId!.trim(),
        if (q?.trim().isNotEmpty ?? false) 'q': q!.trim(),
        if (sort?.trim().isNotEmpty ?? false) 'sort': sort!.trim(),
        if (priceType?.trim().isNotEmpty ?? false)
          'price_type': priceType!.trim(),
        if (promotionType?.trim().isNotEmpty ?? false)
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
        if (locationId?.trim().isNotEmpty ?? false)
          'location': locationId!.trim(),
        if (categoryId?.trim().isNotEmpty ?? false)
          'category': categoryId!.trim(),
        if (q?.trim().isNotEmpty ?? false) 'q': q!.trim(),
        if (sort?.trim().isNotEmpty ?? false) 'sort': sort!.trim(),
        if (promotionType?.trim().isNotEmpty ?? false)
          'promotion_type': promotionType!.trim(),
        if (priceType?.trim().isNotEmpty ?? false)
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
      final res = await _dio.get<Map<String, dynamic>>(
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
      final res = await _dio.get<Map<String, dynamic>>(
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
      final res = await _dio.get<Map<String, dynamic>>(
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
      final res = await _dio.get<Map<String, dynamic>>(
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
      final res = await _dio.post<Map<String, dynamic>>(
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
    int limit = 20,
    int offset = 0,
    String? sort,
    String? q,
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool? verifiedSeller,
  }) async {
    try {
      if (limit < 1 || limit > 50) {
        return Either.left(const Failure('Invalid wishlist page size.'));
      }
      if (offset < 0) {
        return Either.left(const Failure('Invalid wishlist page offset.'));
      }
      if (sort != null && !_allowedSorts.contains(sort)) {
        return Either.left(Failure('Invalid sort value: $sort'));
      }

      final cleanQuery = q?.trim();
      if (cleanQuery != null &&
          cleanQuery.isNotEmpty &&
          cleanQuery.length < 2) {
        return Either.left(
          const Failure('Enter at least two characters to search.'),
        );
      }

      final res = await _client.get(
        ApiEndpoints.listWishlistEndpoint,
        marketContext: true,
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (sort?.trim().isNotEmpty ?? false) 'sort': sort!.trim(),
          if (cleanQuery?.isNotEmpty ?? false) 'q': cleanQuery,
          'price_min': ?priceMin,
          'price_max': ?priceMax,
          'rating_min': ?ratingMin,
          if (verifiedSeller != null)
            'verified_seller': _binaryFlag(verifiedSeller),
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
    required bool wishlisted,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.toggleWishlistEndpoint,
        data: {'ad_id': adId.trim(), 'wishlisted': _binaryFlag(wishlisted)},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to update wishlist.'));
    }
  }
}

int _binaryFlag(bool value) => switch (value) {
  true => 1,
  false => 0,
};
