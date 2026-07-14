class ToggleRepostResult {
  const ToggleRepostResult({
    required this.shortId,
    required this.reposted,
    this.repostCount,
    this.shareCount,
  });

  final String shortId;
  final bool reposted;
  final int? repostCount;
  final int? shareCount;
}
