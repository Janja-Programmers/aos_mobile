import '../../../shared/products/domain/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    super.oldPrice,
    required super.imageUrl,
    required super.category,
    required super.shopName,
    required super.sellerName,
    required super.phoneNumber,
    required super.rating,
    required super.inStock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      oldPrice:
          json['oldPrice'] != null
              ? (json['oldPrice'] as num).toDouble()
              : null,
      imageUrl: json['imageUrl'],
      category: json['category'],
      shopName: json['shopName'],
      sellerName: json['sellerName'],
      phoneNumber: json['phoneNumber'],
      rating: (json['rating'] as num).toDouble(),
      inStock: json['inStock'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'oldPrice': oldPrice,
    'imageUrl': imageUrl,
    'category': category,
    'shopName': shopName,
    'sellerName': sellerName,
    'phoneNumber': phoneNumber,
    'rating': rating,
    'inStock': inStock,
  };
}
