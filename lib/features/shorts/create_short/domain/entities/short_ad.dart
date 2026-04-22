import 'package:equatable/equatable.dart';

class ShortAd extends Equatable {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String? thumbnail;

  const ShortAd({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    this.thumbnail,
  });

  @override
  List<Object?> get props => [id, title, price, currency, thumbnail];
}
