import 'package:equatable/equatable.dart';

class ItemPrice extends Equatable {
  final String itemCode;
  final String uom;
  final String priceList;
  final double? priceListRate;
  final String? owner;

  const ItemPrice({
    required this.itemCode,
    required this.uom,
    required this.priceList,
    this.priceListRate,
    this.owner,
  });

  @override
  List<Object?> get props => [itemCode, uom, priceList, priceListRate, owner];
}
