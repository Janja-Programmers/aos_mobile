import '../../domain/entity/stock.dart';

import 'stock_item.dart';

class StockEntryModel {
  final String id;
  final int docstatus;
  final DateTime? modified;
  final List<StockEntryItemModel> items;

  StockEntryModel({
    required this.id,
    required this.docstatus,
    this.modified,
    required this.items,
  });

  factory StockEntryModel.fromJson(Map<String, dynamic> json) {
    return StockEntryModel(
      id: json['name'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      items:
          (json['items'] as List<dynamic>? ?? [])
              .map((e) => StockEntryItemModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': id,
      'docstatus': docstatus,
      'items': items.map((e) => e.toJson()).toList(),
    };

    if (modified != null) {
      data['modified'] = modified!.toIso8601String();
    }

    return data;
  }

  StockEntry toEntity() => StockEntry(
    id: id,
    docstatus: docstatus,
    modified: modified ?? DateTime.now(),
    items: items.map((e) => e.toEntity()).toList(),
  );

  static StockEntryModel fromEntity(StockEntry entry) => StockEntryModel(
    id: entry.id,
    docstatus: entry.docstatus,
    modified: entry.modified,
    items: entry.items.map((e) => StockEntryItemModel.fromEntity(e)).toList(),
  );
}
