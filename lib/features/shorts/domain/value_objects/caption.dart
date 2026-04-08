import 'package:equatable/equatable.dart';

class Caption extends Equatable {
  static const int maxLength = 2200;

  final String value;

  const Caption._(this.value);

  /// Factory ensures normalization + validation
  factory Caption(String input) {
    final trimmed = input.trim();

    if (trimmed.length > maxLength) {
      throw ArgumentError('Caption cannot exceed $maxLength characters');
    }

    return Caption._(trimmed);
  }

  bool get isEmpty => value.isEmpty;

  bool get isNotEmpty => value.isNotEmpty;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
