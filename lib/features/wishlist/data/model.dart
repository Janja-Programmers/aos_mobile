import '../domain/wishlist_item.dart';

class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.price,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'imageUrl': imageUrl, 'price': price};
  }
}

extension WishlistItemMapper on WishlistItem {
  WishlistItemModel toModel() =>
      WishlistItemModel(id: id, title: title, imageUrl: imageUrl, price: price);
}
