import 'package:flutter/material.dart';

import '/core/utils/formatters.dart';
import '/features/stock/domain/entity/stock_item.dart';

class ItemRowController {
  final formKey = GlobalKey<FormState>();

  final itemCode = TextEditingController();
  final itemName = TextEditingController();
  final qty = TextEditingController();
  final valuationRate = TextEditingController();

  StockEntryItem get entry => StockEntryItem(
    itemCode: itemCode.text.trim(),
    itemName: itemName.text.trim(),
    qty: double.tryParse(qty.text.trim()) ?? 0,
    valuationRate: double.tryParse(valuationRate.text.trim()) ?? 0,
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
    qty.text = formatCurrency(item.qty);
    valuationRate.text = formatCurrency(item.valuationRate);
  }

  bool validate() => formKey.currentState?.validate() ?? false;
}
