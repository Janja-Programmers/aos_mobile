class ShortSound {
  final String id;
  final String title;
  final String artist;
  final String? fileUrl;
  final int durationSeconds;
  final int usageCount;
  final bool isFavorite;
  final bool isCommercialSafe;

  const ShortSound({
    required this.id,
    required this.title,
    required this.artist,
    this.fileUrl,
    required this.durationSeconds,
    this.usageCount = 0,
    this.isFavorite = false,
    this.isCommercialSafe = true,
  });

  static const original = ShortSound(
    id: 'original',
    title: 'Original audio',
    artist: 'Use the video audio',
    durationSeconds: 0,
  );
}
