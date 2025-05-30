import 'package:flutter/material.dart';

class StockItemFormData {
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();

  void dispose() {
    itemCodeController.dispose();
    quantityController.dispose();
    itemPriceController.dispose();
  }
}
