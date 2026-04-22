class InvalidShortStateException implements Exception {
  final String message;

  const InvalidShortStateException(this.message);

  @override
  String toString() => 'InvalidShortStateException: $message';
}
