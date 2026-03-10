import 'dart:io';

import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

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
        withCountry: true,
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

  Future<Either<Failure, Map<String, String>>> uploadMedia({
    required File file,
  }) async {
    try {
      final filename = file.path.split(Platform.pathSeparator).last;

      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: filename),
        'is_private': '0',
      });

      final res = await _dio.post(ApiEndpoints.uploadFileEndpoint, data: form);

      final body = res.data;

      if (body is Map && body['message'] is Map) {
        final msg = Map<String, dynamic>.from(body['message']);

        final url = (msg['file_url'] ?? '').toString();
        final fileId = (msg['name'] ?? '').toString();

        if (url.isNotEmpty && fileId.isNotEmpty) {
          return Either.right({'url': url, 'fileId': fileId});
        }
      }

      return Either.left(const Failure('Failed to upload file.'));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to upload file.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> deleteFile({
    required String fileId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.deleteFileEndpoint,
        queryParameters: {'file_id': fileId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch ad details.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> removeBackground({
    required String fileId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.removeBackgroundEndpoint,
        queryParameters: {'file_id': fileId},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to remove background.'));
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

  Future<Either<Failure, Map<String, dynamic>>> updateAdDraft({
    required String draftId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.updateAdDraftEndpoint,
        queryParameters: {'draft_id': draftId, "payload": payload},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to create ad.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> submitAdDraft({
    required String adId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.submitAdDraftEndpoint,
        queryParameters: {'draft_id': adId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to create ad.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> saveAdDraft({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.saveAdDraftEndpoint,
        data: {'payload_json': payload},
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
    required String country,
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
        'country': country,

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
        ApiEndpoints.listAdsEndpoint,
        withCountry: true,
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
    // required String country,
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
        // 'country': country,
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
        withCountry: true,
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
    String status = 'Active',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.myAdsEndpoint,
        queryParameters: {'status': status, 'limit': limit, 'offset': offset},
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

  Future<Either<Failure, Map<String, dynamic>>> getAdReviews({
    required String adId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.getAdReviewsEndpoint,
        queryParameters: {'ad': adId, 'limit': limit, 'offset': offset},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch reviews.'));
    }
  }

  Future<Either<Failure, void>> createAdReview({
    required String ad,
    required double rating,
    required String title,
    required String comment,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.createAdReviewEndpoint,
        data: {"ad": ad, "rating": rating, "title": title, "comment": comment},
      );

      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to fetch reviews.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> listWishlist({
    int limit = 200,
    int offset = 0,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.listWishlistEndpoint,
        queryParameters: {'limit': limit, 'offset': offset},
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
