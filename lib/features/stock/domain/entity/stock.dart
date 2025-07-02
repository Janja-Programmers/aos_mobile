import 'package:equatable/equatable.dart';

import 'stock_item.dart';

class StockEntry extends Equatable {
  final String id; // name
  final int docstatus; // 0 = Draft, 1 = Submitted, 2 = Cancelled
  final String vendor;
  final List<StockEntryItem> items;

  const StockEntry({
    required this.id,
    required this.docstatus,
    required this.vendor,
    required this.items,
  });

  @override
  List<Object?> get props => [id, docstatus, vendor, items];
}
