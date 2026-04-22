class ShortUploadRequest {
  final String caption;
  final List<String> hashtags;
  final int durationSeconds;

  const ShortUploadRequest({
    required this.caption,
    required this.hashtags,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'caption': caption,
      'hashtags': hashtags,
      'duration_seconds': durationSeconds,
    };
  }
}
