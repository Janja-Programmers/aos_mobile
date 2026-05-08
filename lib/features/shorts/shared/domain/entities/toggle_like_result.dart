import 'package:equatable/equatable.dart';

class ToggleLikeResult extends Equatable {
  final String shortId;
  final bool liked;

  const ToggleLikeResult({required this.shortId, required this.liked});

  @override
  List<Object?> get props => [shortId, liked];
}
