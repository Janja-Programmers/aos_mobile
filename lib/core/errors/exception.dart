import 'package:dio/dio.dart';

import 'failures.dart';

Failure handleException(dynamic e) {
  if (e is DioException) {
    final response = e.response;

    final message =
        response?.data is Map<String, dynamic>
            ? response?.data['message']?.toString() ?? e.message
            : e.message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure();
      case DioExceptionType.connectionError:
        return NetworkFailure();
      default:
        return ServerFailure(message ?? 'Server error');
    }
  } else if (e is FormatException) {
    return const ParsingFailure();
  } else {
    return const UnknownFailure();
  }
}
