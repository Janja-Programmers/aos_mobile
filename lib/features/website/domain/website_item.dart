class WebsiteItem {
  final int? id;
  final String websiteDisplayName;
  final String itemCode;
  final bool isPublished;
  final String? image; // single optional image
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
    this.image, // optional
    this.video,
    this.shortDescription,
    this.fullDescription,
    required this.createdBy,
    required this.createdAt, required List<String> images,
  });
}
