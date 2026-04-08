enum ShortStatus {
  initialized,
  uploaded,
  processing,
  ready,
  failed,
  deleted;

  /// Whether the short can be played
  bool get isPlayable => this == ShortStatus.ready;

  /// Whether the short is still in pipeline
  bool get isProcessing =>
      this == ShortStatus.initialized ||
      this == ShortStatus.uploaded ||
      this == ShortStatus.processing;

  /// Whether retry is allowed
  bool get canRetry => this == ShortStatus.failed;

  /// Whether the short is visible in feeds
  bool get isVisible => this == ShortStatus.ready;

  /// Safe parsing from backend string
  static ShortStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'initialized':
        return ShortStatus.initialized;
      case 'uploaded':
        return ShortStatus.uploaded;
      case 'processing':
        return ShortStatus.processing;
      case 'ready':
        return ShortStatus.ready;
      case 'failed':
        return ShortStatus.failed;
      case 'deleted':
        return ShortStatus.deleted;
      default:
        throw ArgumentError('Invalid ShortStatus: $value');
    }
  }

  /// Convert to backend format
  String toValue() => name;
}
