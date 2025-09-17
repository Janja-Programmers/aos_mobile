import 'package:dio/dio.dart';

import 'failures.dart';

Failure handleException(dynamic e) {
  if (e is DioException) {
    final statusCode = e.response?.statusCode;
    String message = "Something went wrong. Please try again.";

    if (statusCode == 417) {
      message = "Couldn’t complete sign up. Please check your details.";
    } else if (statusCode == 429) {
      message = "Too many attempts. Please try again later.";
    } else if (e.response?.data is Map<String, dynamic>) {
      message = e.response?.data['message']?.toString() ?? message;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure();
      case DioExceptionType.connectionError:
        return NetworkFailure();
      default:
        return ServerFailure(message);
    }
  }

  if (e is FormatException) return const ParsingFailure();
  return const UnknownFailure();
}
