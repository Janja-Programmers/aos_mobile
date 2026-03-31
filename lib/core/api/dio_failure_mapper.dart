import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/failure.dart';

/// Convert Dio exceptions into a user-friendly [Failure].
Failure mapDioException(DioException e) {
  // Network / connection layer
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const Failure(
        'Request timed out. Please try again.',
        type: FailureType.timeout,
      );

    case DioExceptionType.badCertificate:
    case DioExceptionType.connectionError:
      return const Failure(
        'Network error. Check your internet connection.',
        type: FailureType.network,
      );

    case DioExceptionType.cancel:
      return const Failure('Request cancelled.', type: FailureType.unknown);

    case DioExceptionType.unknown:
      // Can be SocketException etc.
      return const Failure(
        'Network error. Please try again.',
        type: FailureType.network,
      );

    case DioExceptionType.badResponse:
      break; // handled below using status code
  }

  final status = e.response?.statusCode;
  final messageFromServer = _extractServerMessage(e.response?.data);

  print('STATUS: $status');
  print('RAW RESPONSE: ${e.response?.data}');
  print('EXTRACTED MESSAGE: $messageFromServer');

  if (status == 401) {
    return Failure(
      messageFromServer ?? 'Unauthorized. Please log in again.',
      statusCode: status,
      type: FailureType.unauthorized,
    );
  }

  if (status == 403) {
    return Failure(
      messageFromServer ?? 'Forbidden.',
      statusCode: status,
      type: FailureType.forbidden,
    );
  }

  if (status == 404) {
    return Failure(
      messageFromServer ?? 'Not found.',
      statusCode: status,
      type: FailureType.notFound,
    );
  }

  if (status == 429) {
    return Failure(
      messageFromServer ?? 'Too many requests. Please slow down.',
      statusCode: status,
      type: FailureType.rateLimited,
    );
  }

  if (status == 417) {
    return Failure(
      messageFromServer ?? 'Request failed.',
      statusCode: status,
      type: FailureType.server,
    );
  }

  if (status != null && status >= 500) {
    return Failure(
      messageFromServer ?? 'Server error. Please try again later.',
      statusCode: status,
      type: FailureType.server,
    );
  }

  return Failure(
    messageFromServer ?? 'Something went wrong. Please try again.',
    statusCode: status,
    type: FailureType.unknown,
  );
}

String? _extractServerMessage(dynamic data) {
  // Expecting one of:
  // 1) {message: {ok: false, message: "..."}}
  // 2) {message: "..."}
  // 3) {ok: false, message: "..."}
  try {
    if (data is Map) {
      // 🔥 Handle Frappe errors
      if (data['_server_messages'] != null) {
        final messages = data['_server_messages'];
        if (messages is List && messages.isNotEmpty) {
          final parsed = messages.first;
          if (parsed is String) {
            final decoded = parsed;
            return decoded;
          }
        }
      }

      final msg = data['message'];
      if (msg is Map && msg['message'] != null) {
        return msg['message'].toString();
      }
      if (msg != null && msg is! Map) {
        return msg.toString();
      }
    }
  } catch (_) {
    // ignore
  }
  return null;
}
