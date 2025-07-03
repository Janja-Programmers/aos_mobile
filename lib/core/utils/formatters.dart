import 'dart:convert';

import 'package:dartz/dartz.dart';

import '/core/di/service_locator.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import '../constants/const.dart';
import '../errors/failures.dart';

const String baseUrl = BASE_URL;

String resolveImageUrl(String? relativePath) {
  if (relativePath == null || relativePath.isEmpty) return '';
  if (relativePath.startsWith('http')) return relativePath;
  return '$baseUrl$relativePath';
}

Future<Either<Failure, List<Map<String, dynamic>>>> fetchFilteredList({
  required String doctype,
  required String field,
  required String value,
  String orderBy = 'creation desc',
}) async {
  try {
    final client = sl<APIClient>();
    final res = await client.client.get(
      '/api/resource/$doctype',
      queryParameters: {
        'order_by': orderBy,
        'filters': jsonEncode([
          [field, '=', value],
        ]),
      },
    );

    final List<dynamic> list = res.data['data'];
    return Right(List<Map<String, dynamic>>.from(list));
  } catch (e) {
    return Left(handleException(e));
  }
}
