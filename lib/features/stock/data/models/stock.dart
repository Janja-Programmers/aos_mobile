import '../../domain/entity/stock.dart';

import 'stock_item.dart';

class StockEntryModel {
  final String id;
  final int docstatus;
  final String vendor;
  final List<StockEntryItemModel> items;

  StockEntryModel({
    required this.id,
    required this.docstatus,
    required this.vendor,
    required this.items,
  });

  factory StockEntryModel.fromJson(Map<String, dynamic> json) {
    return StockEntryModel(
      id: json['name'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      vendor: json['vendor'] ?? '',
      items:
          (json['items'] as List)
              .map((e) => StockEntryItemModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': id,
      'docstatus': docstatus,
      'vendor': vendor,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  StockEntry toEntity() => StockEntry(
    id: id,
    docstatus: docstatus,
    vendor: vendor,
    items: items.map((e) => e.toEntity()).toList(),
  );

  static StockEntryModel fromEntity(StockEntry entry) => StockEntryModel(
    id: entry.id,
    docstatus: entry.docstatus,
    vendor: entry.vendor,
    items: entry.items.map((e) => StockEntryItemModel.fromEntity(e)).toList(),
  );
}
