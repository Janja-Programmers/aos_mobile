class ProductModel {
  final String name;
  final String itemName;
  final double itemPrice;
  final String category;
  final int isStockItem;
  final String? vendor;
  final String? image;
  final String? demoVideo;
  final String? websiteDescription;
  final String? shortWebsiteDescription;
  final List<WebsiteSpecification>? websiteSpecifications;

  ProductModel({
    required this.name,
    required this.itemName,
    required this.itemPrice,
    required this.category,
    this.isStockItem = 0,
    this.vendor,
    this.image,
    this.demoVideo,
    this.websiteDescription,
    this.shortWebsiteDescription,
    this.websiteSpecifications,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    name: json['name'],
    itemName: json['item_name'],
    itemPrice: (json['item_price'] ?? 0).toDouble(),
    category: json['category'],
    isStockItem: json['is_stock_item'] ?? 0,
    vendor: json['vendor'],
    image: json['image'],
    demoVideo: json['demo_video'],
    websiteDescription: json['web_long_description'],
    shortWebsiteDescription: json['short_description'],
    websiteSpecifications:
        (json['website_specifications'] as List?)
            ?.map((e) => WebsiteSpecification.fromJson(e))
            .toList(),
  );

  Map<String, dynamic> toMapForApi() => {
    "name": name,
    "item_name": itemName,
    "item_price": itemPrice,
    "category": category,
    "is_stock_item": isStockItem,
    "vendor": vendor,
    "web_long_description": websiteDescription,
    "short_description": shortWebsiteDescription,
    "image": image,
    "demo_video": demoVideo,
    "website_specifications":
        websiteSpecifications
            ?.map(
              (e) => {
                "doctype": "Product Website Specification",
                "label": e.label,
                "description": e.description,
              },
            )
            .toList(),
  };
}

class WebsiteSpecification {
  final String label;
  final String description;

  WebsiteSpecification({required this.label, required this.description});

  factory WebsiteSpecification.fromJson(Map<String, dynamic> json) =>
      WebsiteSpecification(
        label: json['label'] ?? '',
        description: json['description'] ?? '',
      );
}
