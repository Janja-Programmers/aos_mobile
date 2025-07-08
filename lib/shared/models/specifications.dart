import 'package:equatable/equatable.dart';

class Specification extends Equatable {
  final String label;
  final String description;

  const Specification({required this.label, required this.description});

  @override
  List<Object?> get props => [label, description];
}
