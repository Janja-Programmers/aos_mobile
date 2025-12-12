import '../domain/wishlist_item.dart';

class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.price,
    required super.itemGroup,
    required super.inStock,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      itemGroup: json['itemGroup'] ?? '',
      inStock: json['inStock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'itemGroup': itemGroup,
      'inStock': inStock,
    };
  }
}
