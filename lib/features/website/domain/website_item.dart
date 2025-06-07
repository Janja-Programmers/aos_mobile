class WebsiteItem {
  final int? id;
  final String websiteDisplayName;
  final String itemCode;
  final bool isPublished;
  final List<String> images;
  final String? video;
  final String? shortDescription;
  final String? fullDescription;
  final int createdBy;
  final DateTime createdAt;

  WebsiteItem({
    this.id,
    required this.websiteDisplayName,
    required this.itemCode,
    this.isPublished = false,
    this.images = const [],
    this.video,
    this.shortDescription,
    this.fullDescription,
    required this.createdBy,
    required this.createdAt,
  });
}
