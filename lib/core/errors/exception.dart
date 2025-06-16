import 'package:dio/dio.dart';

import 'failures.dart';

Failure handleException(dynamic e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure();
      case DioExceptionType.connectionError:
        return NetworkFailure();
      default:
        return ServerFailure(e.message ?? 'Server error');
    }
  } else if (e is FormatException) {
    return ParsingFailure();
  } else {
    return UnknownFailure();
  }
}
