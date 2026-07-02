import 'dart:convert';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:dio/dio.dart';

/// Convert Dio exceptions into a user-friendly [Failure].
Failure mapDioException(DioException e) {
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
      return const Failure(
        'Network error. Please try again.',
        type: FailureType.network,
      );
    case DioExceptionType.badResponse:
      break;
  }

  final status = e.response?.statusCode;
  final messageFromServer = _extractServerMessage(e.response?.data);

  appLogger.i('STATUS: $status');
  appLogger.i('RAW RESPONSE: ${e.response?.data}');
  appLogger.i('EXTRACTED MESSAGE: $messageFromServer');

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

String? _extractServerMessage(Object? data) {
  try {
    if (data is! Map) {
      return null;
    }

    final serverMessages = data['_server_messages'];
    final serverMessage = _extractFrappeServerMessage(serverMessages);
    if (serverMessage != null) {
      return serverMessage;
    }

    final msg = data['message'];
    if (msg is Map) {
      final nested = msg['message'];
      if (nested != null) {
        return nested.toString();
      }
    }

    if (msg != null) {
      return msg.toString();
    }
  } catch (_) {
    // Keep failure mapping defensive; malformed server errors should not crash.
  }
  return null;
}

String? _extractFrappeServerMessage(Object? raw) {
  if (raw == null) {
    return null;
  }

  try {
    final Object? decoded = raw is String ? jsonDecode(raw) : raw;
    final List<Object?> messages = decoded is Iterable<Object?>
        ? decoded.toList(growable: false)
        : decoded is Iterable
        ? decoded.cast<Object?>().toList(growable: false)
        : <Object?>[];

    if (messages.isEmpty) {
      return null;
    }

    final first = messages.first;
    if (first is! String) {
      return first?.toString();
    }

    final inner = jsonDecode(first);
    if (inner is Map && inner['message'] != null) {
      return inner['message'].toString();
    }

    return first;
  } catch (_) {
    return raw.toString();
  }
}
