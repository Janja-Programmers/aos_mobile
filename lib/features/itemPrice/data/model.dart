import '../domain/item_price.dart';

class ItemPriceModel {
  final String itemCode;
  final String uom;
  final String priceList;
  final double? priceListRate;
  final String? owner;

  ItemPriceModel({
    required this.itemCode,
    required this.uom,
    required this.priceList,
    this.priceListRate,
    this.owner,
  });

  // ---------- JSON ↔︎ Model ----------
  factory ItemPriceModel.fromJson(Map<String, dynamic> json) => ItemPriceModel(
    itemCode: json['item_code'] as String,
    uom: json['uom'] as String,
    priceList: json['price_list'] as String,
    priceListRate:
        json['price_list_rate'] != null
            ? (json['price_list_rate'] as num).toDouble()
            : null,
    owner: json['owner'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'uom': uom,
    'price_list': priceList,
    if (priceListRate != null) 'price_list_rate': priceListRate,
    'owner': owner,
  };

  // ---------- Model ↔︎ Entity ----------
  factory ItemPriceModel.fromEntity(ItemPrice e) => ItemPriceModel(
    itemCode: e.itemCode,
    uom: e.uom,
    priceList: e.priceList,
    priceListRate: e.priceListRate,
    owner: e.owner,
  );

  ItemPrice toEntity() => ItemPrice(
    itemCode: itemCode,
    uom: uom,
    priceList: priceList,
    priceListRate: priceListRate,
    owner: owner,
  );
}
