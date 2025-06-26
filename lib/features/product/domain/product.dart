class Product {
  final String name;
  final String itemName;
  final double itemPrice;
  final String category;
  final String? vendor;
  final String? image;
  final String? slideShow;
  final String? demoVideo;
  final String? websiteDescription;
  final String? shortWebsiteDescription;
  final List<String>? websiteSpecifications;

  const Product({
    required this.name,
    required this.itemName,
    required this.itemPrice,
    required this.category,
    this.vendor,
    this.image,
    this.slideShow,
    this.demoVideo,
    this.websiteDescription,
    this.shortWebsiteDescription,
    this.websiteSpecifications,
  });
}
