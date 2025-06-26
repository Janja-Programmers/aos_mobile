import '../domain/product.dart';

class ProductModel {
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

  ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name'],
      itemName: json['item_name'],
      itemPrice: (json['item_price'] as num).toDouble(),
      category: json['category'],
      vendor: json['vendor'],
      image: json['image'],
      slideShow: json['slide_show'],
      demoVideo: json['demo_video'],
      websiteDescription: json['website_description'],
      shortWebsiteDescription: json['short_website_description'],
      websiteSpecifications:
          (json['website_specifications'] as List<dynamic>?)
              ?.map((spec) => spec as String)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'item_name': itemName,
      'item_price': itemPrice,
      'category': category,
      'vendor': vendor,
      'image': image,
      'slide_show': slideShow,
      'demo_video': demoVideo,
      'website_description': websiteDescription,
      'short_website_description': shortWebsiteDescription,
      'website_specifications': websiteSpecifications,
    };
  }

  Product toEntity() => Product(
    name: name,
    itemName: itemName,
    itemPrice: itemPrice,
    category: category,
    vendor: vendor,
    image: image,
    slideShow: slideShow,
    demoVideo: demoVideo,
    websiteDescription: websiteDescription,
    shortWebsiteDescription: shortWebsiteDescription,
    websiteSpecifications: websiteSpecifications,
  );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      name: product.name,
      itemName: product.itemName,
      itemPrice: product.itemPrice,
      category: product.category,
      vendor: product.vendor,
      image: product.image,
      slideShow: product.slideShow,
      demoVideo: product.demoVideo,
      websiteDescription: product.websiteDescription,
      shortWebsiteDescription: product.shortWebsiteDescription,
      websiteSpecifications: product.websiteSpecifications,
    );
  }
}
