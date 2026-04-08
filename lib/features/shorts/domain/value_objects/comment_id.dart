import 'package:equatable/equatable.dart';

class CommentId extends Equatable {
  final String value;

  const CommentId(this.value)
    : assert(value != '', 'CommentId cannot be empty');

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
