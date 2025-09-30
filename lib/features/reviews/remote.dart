import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '/core/constants/const.dart';

import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';
import '/core/utils/snackbar.dart';
import '/core/di/service_locator.dart';

import 'resp.dart';

Future<ReviewsResponseModel> fetchReviews(
  String itemCode, {
  required BuildContext context,
}) async {
  try {
    final client = sl<APIClient>().client;
    final response = await client.post(
      ApiRoutes.getProductReviews,
      data: {"web_item": itemCode},
    );

    final msg = response.data["message"];
    final result = ReviewsResponseModel.fromJson(msg);

    appLogger.i("Fetched ${result.totalReviews} reviews for $itemCode ✅");
    return result;
  } on DioException catch (e, s) {
    appLogger.e("Fetch product reviews failed", error: e, stackTrace: s);
    topSnackBar(context, "Unable to load reviews", type: TopSnackType.error);
    rethrow;
  } catch (e, s) {
    appLogger.e("Unexpected error in fetchReviews", error: e, stackTrace: s);
    topSnackBar(context, "Something went wrong", type: TopSnackType.error);
    rethrow;
  }
}
