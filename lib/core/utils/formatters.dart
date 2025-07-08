import 'package:intl/intl.dart';

import '../constants/const.dart';

const String baseUrl = BASE_URL;

String resolveImageUrl(String? relativePath) {
  if (relativePath == null || relativePath.isEmpty) return '';
  if (relativePath.startsWith('http')) return relativePath;
  return '$baseUrl$relativePath';
}

String formatCurrency(num amount) {
  final format = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'Sh ',
    decimalDigits: 2,
  );
  return format.format(amount);
}
