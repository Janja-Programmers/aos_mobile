import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:dio/dio.dart';

/// Unwraps the Frappe response envelope while preserving backend error IDs.
Either<Failure, Map<String, dynamic>> unwrapFrappe(Response<Object?> res) {
  try {
    final raw = res.data;
    if (raw is! Map<Object?, Object?>) {
      return Either.left(
        const Failure(
          'Unexpected response from server',
          type: FailureType.parse,
        ),
      );
    }

    final root = asJsonMap(raw);
    final Object? message = root['message'];
    final Map<String, dynamic> payload = message is Map<Object?, Object?>
        ? asJsonMap(message)
        : root;

    if (payload['ok'] == false || _hasError(payload)) {
      return Either.left(
        Failure.fromServerPayload(payload, statusCode: res.statusCode),
      );
    }

    if (message != null && message is! Map<Object?, Object?>) {
      return Either.right(<String, dynamic>{
        'ok': true,
        'message': message.toString(),
      });
    }

    return Either.right(payload);
  } catch (_) {
    return Either.left(
      const Failure('Unexpected response from server', type: FailureType.parse),
    );
  }
}

bool _hasError(Map<String, dynamic> payload) {
  final error = payload['error']?.toString().trim() ?? '';
  return error.isNotEmpty && error.toLowerCase() != 'null';
}
