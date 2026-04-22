class ShortViewerStateModel {
  final bool liked;
  final bool watched;
  final double watchProgress;

  const ShortViewerStateModel({
    required this.liked,
    required this.watched,
    required this.watchProgress,
  });

  factory ShortViewerStateModel.fromJson(Map<String, dynamic> json) {
    return ShortViewerStateModel(
      liked: json['liked'] ?? false,
      watched: json['watched'] ?? false,
      watchProgress: (json['watch_progress'] ?? 0).toDouble(),
    );
  }
}
