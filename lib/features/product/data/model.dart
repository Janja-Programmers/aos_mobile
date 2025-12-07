import 'dart:io';
import '../domain/product.dart';

class ProductModel {
  final String name;
  final String itemName;
  final double itemPrice;
  final String category;
  final int? isStockItem;
  final String? vendor;
  final String? image;
  final File? imageFile;
  final String? slideShow;
  final String? demoVideo;
  final File? videoFile;
  final String? websiteDescription;
  final String? shortWebsiteDescription;
  final List<WebsiteSpecificationModel>? websiteSpecifications;
  final List<AdditionalImagesModel>? additionalImages;

  ProductModel({
    required this.name,
    required this.itemName,
    required this.itemPrice,
    required this.category,
    this.isStockItem,
    this.vendor,
    this.image,
    this.imageFile,
    this.slideShow,
    this.demoVideo,
    this.videoFile,
    this.websiteDescription,
    this.shortWebsiteDescription,
    this.websiteSpecifications,
    this.additionalImages,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name'] ?? '',
      itemName: json['item_name'] ?? '',
      itemPrice: (json['item_price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      isStockItem: json['is_stock_item'],
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
      additionalImages:
          (json['additional_images'] as List<dynamic>?)
              ?.map((e) => AdditionalImagesModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'item_name': itemName,
      'item_price': itemPrice,
      'category': category,
      'is_stock_item': isStockItem,
      'vendor': vendor,
      'image': image,
      'slide_show': slideShow,
      'demo_video': demoVideo,
      'web_long_description': websiteDescription,
      'short_description': shortWebsiteDescription,
      'website_specifications':
          websiteSpecifications?.map((e) => e.toJson()).toList(),
      'additional_images': additionalImages?.map((e) => e.toJson()).toList(),
    };
  }

  Product toEntity() => Product(
    name: name,
    itemName: itemName,
    itemPrice: itemPrice,
    category: category,
    isStockItem: isStockItem,
    vendor: vendor,
    image: image,
    slideShow: slideShow,
    demoVideo: demoVideo,
    websiteDescription: websiteDescription,
    shortWebsiteDescription: shortWebsiteDescription,
    websiteSpecifications:
        websiteSpecifications?.map((e) => e.toEntity()).toList(),
    additionalImages: additionalImages?.map((e) => e.toEntity()).toList(),
  );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      name: product.name,
      itemName: product.itemName,
      itemPrice: product.itemPrice,
      category: product.category,
      isStockItem: product.isStockItem,
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
  final String? name;
  final String label;
  final String description;

  WebsiteSpecificationModel({
    this.name,
    required this.label,
    required this.description,
  });

  factory WebsiteSpecificationModel.fromJson(Map<String, dynamic> json) {
    return WebsiteSpecificationModel(
      name: json['name'],
      label: json['label'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    'label': label,
    'description': description,
  };

  WebsiteSpecification toEntity() =>
      WebsiteSpecification(name: name, label: label, description: description);

  factory WebsiteSpecificationModel.fromEntity(WebsiteSpecification spec) {
    return WebsiteSpecificationModel(
      name: spec.name,
      label: spec.label,
      description: spec.description,
    );
  }
}

class AdditionalImagesModel {
  final File productImages;

  AdditionalImagesModel({required this.productImages});

  factory AdditionalImagesModel.fromJson(Map<String, dynamic> json) {
    return AdditionalImagesModel(
      productImages: json['additional_images'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'additional_Images': productImages};

  AdditionalImages toEntity() => AdditionalImages(productImages: productImages);

  factory AdditionalImagesModel.fromEntity(AdditionalImages img) {
    return AdditionalImagesModel(productImages: img.productImages);
  }
}
