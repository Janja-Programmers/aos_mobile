import 'package:flutter/material.dart';

import '/features/stock/domain/entity/stock_item.dart';

class ItemRowController {
  final itemCode = TextEditingController();
  final itemName = TextEditingController();
  final qty = TextEditingController();
  final valuationRate = TextEditingController();

  StockEntryItem get entry => StockEntryItem(
    itemCode: itemCode.text.trim(),
    itemName: itemName.text.trim(),
    qty: double.tryParse(qty.text) ?? 0,
    valuationRate: double.tryParse(valuationRate.text) ?? 0,
  );

  void dispose() {
    itemCode.dispose();
    itemName.dispose();
    qty.dispose();
    valuationRate.dispose();
  }

  void populateFromItem(StockEntryItem item) {
    itemCode.text = item.itemCode;
    itemName.text = item.itemName;
    qty.text = item.qty.toString();
    valuationRate.text = item.valuationRate.toString();
  }

  bool get isValid =>
      itemCode.text.trim().isNotEmpty &&
      qty.text.trim().isNotEmpty &&
      valuationRate.text.trim().isNotEmpty &&
      double.tryParse(qty.text.trim()) != null &&
      double.tryParse(valuationRate.text.trim()) != null;
}
