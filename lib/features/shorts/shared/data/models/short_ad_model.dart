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
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      thumbnail: json['thumbnail'],
    );
  }
}
