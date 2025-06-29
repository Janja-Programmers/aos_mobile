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
  final List<WebsiteSpecificationModel>? websiteSpecifications;

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
      websiteDescription: json['web_long_description'],
      shortWebsiteDescription: json['short_description'],
      websiteSpecifications:
          (json['website_specifications'] as List<dynamic>?)
              ?.map((e) => WebsiteSpecificationModel.fromJson(e))
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
      'web_long_description': websiteDescription,
      'short_description': shortWebsiteDescription,
      'website_specifications':
          websiteSpecifications?.map((e) => e.toJson()).toList(),
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
    websiteSpecifications:
        websiteSpecifications?.map((e) => e.toEntity()).toList(),
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
      websiteSpecifications:
          product.websiteSpecifications
              ?.map((e) => WebsiteSpecificationModel.fromEntity(e))
              .toList(),
    );
  }
}

class WebsiteSpecificationModel {
  final String label;
  final String description;

  WebsiteSpecificationModel({required this.label, required this.description});

  factory WebsiteSpecificationModel.fromJson(Map<String, dynamic> json) {
    return WebsiteSpecificationModel(
      label: json['label'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'description': description};

  WebsiteSpecification toEntity() =>
      WebsiteSpecification(label: label, description: description);

  factory WebsiteSpecificationModel.fromEntity(WebsiteSpecification spec) {
    return WebsiteSpecificationModel(
      label: spec.label,
      description: spec.description,
    );
  }
}
