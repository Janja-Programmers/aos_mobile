class WishlistItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;

  const WishlistItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
  });

  List<Object?> get props => [id, title, imageUrl, price];
}
