import 'stock_item.dart';

class StockEntry {
  final int? id;
  final DateTime date;
  final String company;
  final String stockEntryType;
  final String targetWarehouse;
  final int createdBy;
  final List<StockItem> items;

  StockEntry({
    this.id,
    required this.date,
    this.company = 'Ownashop',
    this.stockEntryType = 'Material Receipt',
    this.targetWarehouse = 'Stores',
    required this.createdBy,
    required this.items,
  });
}
