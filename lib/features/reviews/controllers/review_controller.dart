import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/reviews/data/review_api.dart';
import 'package:africaonlinestores/features/reviews/domain/review_model.dart';

final reviewsProvider = FutureProvider.family<List<AdReview>, String>((
  ref,
  adId,
) async {
  final api = ref.read(reviewApiProvider);

  final result = await api.getAdReviews(adId: adId);

  return result.fold((failure) => throw Exception(failure.message), (payload) {
    final items = payload['data']?['items'];

    if (items is! List) return const [];

    return items
        .map((e) => AdReview.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  });
});
