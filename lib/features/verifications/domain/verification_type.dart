enum VerificationType {
  individual('Individual'),
  business('Business');

  const VerificationType(this.apiValue);

  final String apiValue;

  static VerificationType fromApiValue(
    Object? value, {
    required VerificationType fallback,
  }) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';

    return switch (normalized) {
      'individual' || 'user' || 'personal' => VerificationType.individual,
      'business' || 'seller' => VerificationType.business,
      _ => fallback,
    };
  }
}
