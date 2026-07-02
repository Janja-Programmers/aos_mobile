import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:dio/dio.dart';

Future<Either<Failure, T>> unwrapAndParse<T>(
  Response<Object?> res,
  T Function(Map<String, dynamic>) parser,
) async {
  final unwrapped = unwrapFrappe(res);

  return unwrapped.fold(Either.left, (json) {
    try {
      return Either.right(parser(json));
    } catch (_) {
      return Either.left(const Failure('Parse error', type: FailureType.parse));
    }
  });
}
