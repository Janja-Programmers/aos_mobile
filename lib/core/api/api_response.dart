import 'package:dio/dio.dart';

import 'package:aos_mobile/core/api/failure.dart';
import 'package:aos_mobile/core/utils/either.dart';

/// Helpers for dealing with Frappe-style responses.
///
/// Frappe often wraps responses like: {"message": {...}}
Either<Failure, Map<String, dynamic>> unwrapFrappe(Response res) {
  final data = res.data;
  try {
    if (data is Map && data['message'] is Map) {
      return Either.right(Map<String, dynamic>.from(data['message'] as Map));
    }

    if (data is Map && data.containsKey('message') && data['message'] is! Map) {
      return Either.right({'ok': true, 'message': data['message'].toString()});
    }

    if (data is Map) {
      return Either.right(Map<String, dynamic>.from(data));
    }
  } catch (_) {
    // fall through to parse failure
  }
  return Either.left(
    const Failure('Unexpected response from server', type: FailureType.parse),
  );
}
