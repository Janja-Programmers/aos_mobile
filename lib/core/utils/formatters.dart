import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '/core/di/service_locator.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import '../constants/const.dart';
import '../errors/failures.dart';

const String baseUrl = ApiRoutes.baseUrl;

String? resolveImageUrl(String? relativePath) {
  if (relativePath == null) return null;

  final trimmed = relativePath.trim();
  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('http')) return trimmed;

  return '$baseUrl$trimmed';
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

String formatCurrency(num amount) {
  final format = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'Sh ',
    decimalDigits: 2,
  );
  return format.format(amount);
}

String cleanHtml(String? input) {
  if (input == null) return '';
  return input.replaceAll(RegExp(r'[^\x20-\x7E\r\n\t]'), '').trim();
}

String formatCompactDateTime(DateTime dateTime) {
  final formatter = DateFormat('MMM d h:mm a');
  return formatter.format(dateTime);
}
