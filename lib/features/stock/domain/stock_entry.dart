// lib/features/stock_entry/domain/stock_entry.dart
import 'package:equatable/equatable.dart';

class StockEntry extends Equatable {
  final String id; // name
  final String stockEntryType; // stock_entry_type
  final String status; // status  (falls back to docstatus)
  final String purpose; // purpose
  final String sourceWarehouse; // to_warehouse / from_warehouse

  const StockEntry({
    required this.id,
    required this.stockEntryType,
    required this.status,
    required this.purpose,
    required this.sourceWarehouse,
  });

  @override
  List<Object?> get props => [
    id,
    stockEntryType,
    status,
    purpose,
    sourceWarehouse,
  ];
}
