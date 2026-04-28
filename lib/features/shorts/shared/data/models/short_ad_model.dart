class ShortAdModel {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String? thumbnail;

  const ShortAdModel({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    this.thumbnail,
  });

  factory ShortAdModel.fromJson(Map<String, dynamic> json) {
    return ShortAdModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
    );
  }

  bool get isEmpty => id.trim().isEmpty;

  bool get isNotEmpty => !isEmpty;
}
