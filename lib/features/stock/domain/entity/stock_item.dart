import 'package:equatable/equatable.dart';

class StockEntryItem extends Equatable {
  final String itemCode; // e.g., STO-ITEM-2025-00019
  final String itemName; // e.g., "Postman1"
  final double qty;
  final double valuationRate;

  const StockEntryItem({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.valuationRate,
  });

  double get totalValue => qty * valuationRate;

  @override
  List<Object?> get props => [itemCode, itemName, qty, valuationRate];
}
