import 'package:africaonlinestores/features/reviews/application/state/review_create_state.dart';
import 'package:africaonlinestores/features/reviews/data/review_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final reviewCreateControllerProvider =
    StateNotifierProvider.family<
      ReviewCreateController,
      ReviewCreateState,
      String
    >((ref, adId) {
      return ReviewCreateController(ref, adId);
    });

class ReviewCreateController extends StateNotifier<ReviewCreateState> {
  ReviewCreateController(this.ref, this.adId)
    : super(const ReviewCreateState());

  final Ref ref;
  final String adId;

  Future<bool> submit({
    required double rating,
    required String title,
    required String comment,
    required List<String> images,
  }) async {
    state = state.copyWith(submitting: true);

    final res = await ref
        .read(reviewApiProvider)
        .createAdReview(
          ad: adId,
          rating: rating,
          title: title,
          comment: comment,
          images: images,
        );

    return res.fold(
      (failure) {
        state = state.copyWith(submitting: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(submitting: false);
        return true;
      },
    );
  }
}
