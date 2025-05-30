import '../../domain/entities/stock_entry.dart';
import '../../domain/entities/stock_item.dart';

class StockEntryModel extends StockEntry {
  StockEntryModel({
    required super.id,
    required super.date,
    required super.company,
    required super.stockEntryType,
    required super.targetWarehouse,
    required super.createdBy,
    required super.items,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'company': company,
    'stock_entry_type': stockEntryType,
    'target_warehouse': targetWarehouse,
    'created_by': createdBy,
  };

  factory StockEntryModel.fromJson(
    Map<String, dynamic> json,
    List<StockItem> items,
  ) {
    return StockEntryModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      company: json['company'],
      stockEntryType: json['stock_entry_type'],
      targetWarehouse: json['target_warehouse'],
      createdBy: json['created_by'],
      items: items,
    );
  }
}
