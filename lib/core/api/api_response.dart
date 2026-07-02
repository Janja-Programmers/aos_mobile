import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:dio/dio.dart';

/// Helpers for dealing with Frappe-style responses.
///
/// Frappe often wraps responses like: {"message": {...}}
Either<Failure, Map<String, dynamic>> unwrapFrappe(Response<Object?> res) {
  final data = res.data;
  try {
    if (data is Map && data['message'] is Map) {
      return Either.right(asJsonMap(data['message'] as Map));
    }

    if (data is Map && data.containsKey('message') && data['message'] is! Map) {
      return Either.right({'ok': true, 'message': data['message'].toString()});
    }

    if (data is Map) {
      return Either.right(asJsonMap(data));
    }
  } catch (_) {
    // fall through to parse failure
  }
  return Either.left(
    const Failure('Unexpected response from server', type: FailureType.parse),
  );
}
