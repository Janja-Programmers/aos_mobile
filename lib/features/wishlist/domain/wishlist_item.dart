class WishlistItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String itemGroup;
  final bool inStock;

  const WishlistItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.itemGroup,
    required this.inStock,
  });

  List<Object?> get props => [id, title, imageUrl, price, itemGroup, inStock];
}
