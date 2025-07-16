import 'package:equatable/equatable.dart';

import 'stock_item.dart';

class StockEntry extends Equatable {
  final String id;
  final int docstatus;
  final DateTime? modified;
  final List<StockEntryItem> items;

  const StockEntry({
    required this.id,
    required this.docstatus,
    this.modified,
    required this.items,
  });

  @override
  List<Object?> get props => [id, docstatus, modified, items];

  StockEntry copyWith({
    String? id,
    int? docstatus,
    DateTime? modified,
    List<StockEntryItem>? items,
  }) {
    return StockEntry(
      id: id ?? this.id,
      docstatus: docstatus ?? this.docstatus,
      modified: modified ?? this.modified,
      items: items ?? this.items,
    );
  }
}
