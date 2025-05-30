class StockItem {
  final int? id;
  final int? stockEntryId; // Foreign key (nullable in domain layer)
  final String targetWarehouse;
  final String itemCode;
  final int quantity;
  final double itemPrice;

  StockItem({
    this.id,
    this.stockEntryId,
    this.targetWarehouse = 'Stores',
    required this.itemCode,
    required this.quantity,
    required this.itemPrice,
  });
}
