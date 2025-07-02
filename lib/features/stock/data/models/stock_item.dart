import '../../domain/entity/stock_item.dart';

class StockEntryItemModel {
  final String itemCode;
  final String itemName;
  final double qty;
  final double valuationRate;

  const StockEntryItemModel({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.valuationRate,
  });

  factory StockEntryItemModel.fromJson(Map<String, dynamic> json) {
    return StockEntryItemModel(
      itemCode: json['item'],
      itemName: json['item_name'] ?? '',
      qty: (json['qty'] ?? 0).toDouble(),
      valuationRate: (json['valuation_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'item': itemCode,
    'item_name': itemName,
    'qty': qty,
    'valuation_rate': valuationRate,
  };

  StockEntryItem toEntity() => StockEntryItem(
    itemCode: itemCode,
    itemName: itemName,
    qty: qty,
    valuationRate: valuationRate,
  );

  factory StockEntryItemModel.fromEntity(StockEntryItem entity) =>
      StockEntryItemModel(
        itemCode: entity.itemCode,
        itemName: entity.itemName,
        qty: entity.qty,
        valuationRate: entity.valuationRate,
      );
}
