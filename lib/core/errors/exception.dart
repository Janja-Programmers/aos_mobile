import 'dart:convert';
import 'package:dio/dio.dart';
import 'failures.dart';

Failure handleException(dynamic e) {
  if (e is DioException) {
    final statusCode = e.response?.statusCode;
    String message = "Something went wrong. Please try again.";

    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      // 1. Frappe "_server_messages"
      if (data["_server_messages"] != null) {
        try {
          final decoded = json.decode(data["_server_messages"]);
          if (decoded is List && decoded.isNotEmpty) {
            message = decoded.first.toString();
          }
        } catch (_) {}
      }
      // 2. Standard "message" field
      else if (data["message"] != null &&
          data["message"].toString().trim().isNotEmpty) {
        message = data["message"].toString();
      }
      // 3. Title fallback
      else if (data["title"] != null) {
        message = data["title"].toString();
      }
    }

    // Status-code–based overrides
    if (statusCode == 417) {
      message = "Couldn’t complete the request. Please check your details.";
    } else if (statusCode == 429) {
      message = "Too many attempts. Please try again later.";
    }

    // Timeouts & network
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
