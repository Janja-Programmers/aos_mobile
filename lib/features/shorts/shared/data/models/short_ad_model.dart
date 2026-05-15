class ShortAdModel {
  final String id;
  final String title;
  final double? price;
  final String? currency;
  final String? thumbnail;

  const ShortAdModel({
    required this.id,
    required this.title,
    this.price,
    this.currency,
    this.thumbnail,
  });

  bool get isEmpty => id.trim().isEmpty;

  factory ShortAdModel.fromJson(Map<String, dynamic> json) {
    return ShortAdModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: json.containsKey('price')
          ? _toNullableDouble(json['price'])
          : null,
      currency: json['currency']?.toString(),
      thumbnail:
          json['thumbnail']?.toString() ??
          json['thumbnail_url']?.toString() ??
          json['image']?.toString(),
    );
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }
}
