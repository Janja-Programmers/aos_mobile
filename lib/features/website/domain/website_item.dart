class WebsiteItem {
  final int? id;
  final String websiteDisplayName;
  final String itemCode;
  final bool isPublished;
  final List<String> images; // 0 or more optional images
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
    this.images = const [], // default to empty list
    this.video,
    this.shortDescription,
    this.fullDescription,
    required this.createdBy,
    required this.createdAt,
  });
}
