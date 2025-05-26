class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final String category;
  final String shopName;
  final String sellerName;
  final String phoneNumber;
  final double rating;
  final bool inStock;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.category,
    required this.shopName,
    required this.sellerName,
    required this.phoneNumber,
    required this.rating,
    required this.inStock,
  });

  List<Object?> get props => [
    id,
    title,
    description,
    price,
    oldPrice,
    imageUrl,
    category,
    shopName,
    sellerName,
    phoneNumber,
    rating,
    inStock,
  ];
}
