import '../../domain/entity/stock.dart';

import 'stock_item.dart';

class StockEntryModel {
  final String id;
  final int docstatus;
  final String vendor;
  final List<StockEntryItemModel> items;

  const StockEntryModel({
    required this.id,
    required this.docstatus,
    required this.vendor,
    required this.items,
  });

  factory StockEntryModel.fromJson(Map<String, dynamic> json) {
    return StockEntryModel(
      id: json['name'],
      docstatus: json['docstatus'] ?? 0,
      vendor: json['vendor'] ?? 'Unknown',
      items:
          (json['items'] as List<dynamic>)
              .map((e) => StockEntryItemModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': id,
    'docstatus': docstatus,
    'vendor': vendor,
    'items': items.map((e) => e.toJson()).toList(),
  };

  StockEntry toEntity() => StockEntry(
    id: id,
    docstatus: docstatus,
    vendor: vendor,
    items: items.map((e) => e.toEntity()).toList(),
  );

  factory StockEntryModel.fromEntity(StockEntry entity) => StockEntryModel(
    id: entity.id,
    docstatus: entity.docstatus,
    vendor: entity.vendor,
    items: entity.items.map((e) => StockEntryItemModel.fromEntity(e)).toList(),
  );
}
