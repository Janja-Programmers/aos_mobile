import '/core/constants/const.dart';
import '/core/utils/api_client.dart';

import 'resp.dart';

import 'package:dio/dio.dart';

class ReviewsRemote {
  final APIClient client;
  ReviewsRemote(this.client);

  Future<ReviewsResponseModel> fetchReviews(String webItem) async {
    final response = await client.client.post(
      ApiRoutes.getProductReviews,
      data: {"web_item": webItem},
    );
    return ReviewsResponseModel.fromJson(response.data["message"]);
  }

  Future<void> postReview({
    required String webItem,
    required String title,
    required String comment,
    required double rating,
  }) async {
    final payload = {
      "web_item": webItem,
      "title": title,
      "rating": rating,
      if (comment.trim().isNotEmpty) "comment": comment.trim(),
    };

    try {
      final res = await client.client.post(
        ApiRoutes.addReview,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (res.statusCode == null ||
          res.statusCode! < 200 ||
          res.statusCode! >= 300) {
        throw Exception("Unexpected status: ${res.statusCode}");
      }
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception("Failed to post review: $message");
    }
  }
}
