import '../domain/stock_entry.dart';

class StockEntryModel extends StockEntry {
  const StockEntryModel({
    required super.id,
    required super.stockEntryType,
    required super.status,
    required super.purpose,
    required super.sourceWarehouse,
  });

  factory StockEntryModel.fromJson(Map<String, dynamic> json) {
    return StockEntryModel(
      id: json['name'],
      stockEntryType: json['stock_entry_type'] ?? '',
      status: json['status'] ?? json['docstatus'].toString(),
      purpose: json['purpose'] ?? '',
      sourceWarehouse: json['from_warehouse'] ?? json['to_warehouse'] ?? '—',
    );
  }
}
