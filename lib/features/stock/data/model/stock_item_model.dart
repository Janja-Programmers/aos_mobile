
import '../../domain/entities/stock_item.dart';

class StockItemModel extends StockItem {
  StockItemModel({
    required super.id,
    required super.stockEntryId,
    required super.targetWarehouse,
    required super.itemCode,
    required super.quantity,
    required super.itemPrice,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'stock_entry_id': stockEntryId,
    'target_warehouse': targetWarehouse,
    'item_code': itemCode,
    'quantity': quantity,
    'item_price': itemPrice,
  };

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'],
      stockEntryId: json['stock_entry_id'],
      targetWarehouse: json['target_warehouse'],
      itemCode: json['item_code'],
      quantity: json['quantity'],
      itemPrice: json['item_price'],
    );
  }
}
