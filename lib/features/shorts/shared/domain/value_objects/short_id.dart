import 'package:equatable/equatable.dart';

class ShortId extends Equatable {
  final String value;

  const ShortId(this.value) : assert(value != '', 'ShortId cannot be empty');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
