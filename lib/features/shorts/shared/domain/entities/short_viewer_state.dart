import 'package:equatable/equatable.dart';

class ShortViewerState extends Equatable {
  final bool liked;
  final bool watched;
  final double watchProgress;

  const ShortViewerState({
    required this.liked,
    required this.watched,
    required this.watchProgress,
  });

  factory ShortViewerState.initial() {
    return const ShortViewerState(
      liked: false,
      watched: false,
      watchProgress: 0,
    );
  }

  ShortViewerState copyWith({
    bool? liked,
    bool? watched,
    double? watchProgress,
  }) {
    return ShortViewerState(
      liked: liked ?? this.liked,
      watched: watched ?? this.watched,
      watchProgress: watchProgress ?? this.watchProgress,
    );
  }

  @override
  List<Object?> get props => [liked, watched, watchProgress];
}
