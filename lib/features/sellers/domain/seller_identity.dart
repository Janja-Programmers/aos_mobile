final RegExp _publicSellerIdPattern = RegExp(r'^SELLER-[A-Z2-7]{20}$');

String? normalizePublicSellerId(Object? value) {
  final clean = value?.toString().trim().toUpperCase() ?? '';
  return _publicSellerIdPattern.hasMatch(clean) ? clean : null;
}

String? firstPublicSellerId(Iterable<Object?> candidates) {
  for (final candidate in candidates) {
    final normalized = normalizePublicSellerId(candidate);
    if (normalized != null) return normalized;
  }
  return null;
}
