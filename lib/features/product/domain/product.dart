import 'dart:io';

class Product {
  final String name;
  final String itemName;
  final double itemPrice;
  final String category;
  final String? vendor;
  final String? image;
  final File? imageFile;
  final String? slideShow;
  final String? demoVideo;
  final File? videoFile;
  final String? websiteDescription;
  final String? shortWebsiteDescription;
  final List<WebsiteSpecification>? websiteSpecifications;

  const Product({
    required this.name,
    required this.itemName,
    required this.itemPrice,
    required this.category,
    this.vendor,
    this.image,
    this.imageFile,
    this.slideShow,
    this.demoVideo,
    this.videoFile,
    this.websiteDescription,
    this.shortWebsiteDescription,
    this.websiteSpecifications,
  });
}

class WebsiteSpecification {
  final String? name;
  final String label;
  final String description;

  WebsiteSpecification({
    this.name,
    required this.label,
    required this.description,
  });
}
