import 'package:flutter/material.dart';
import 'stock_item_form_data.dart';

class StockItemForm extends StatelessWidget {
  final StockItemFormData data;
  final VoidCallback onRemove;

  const StockItemForm({super.key, required this.data, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: data.itemCodeController,
              decoration: InputDecoration(labelText: 'Item Code'),
              validator:
                  (val) =>
                      val == null || val.isEmpty ? 'Enter item code' : null,
            ),
            TextFormField(
              controller: data.quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter quantity';
                final n = int.tryParse(val);
                if (n == null || n <= 0) return 'Enter valid quantity';
                return null;
              },
            ),
            TextFormField(
              controller: data.itemPriceController,
              decoration: InputDecoration(labelText: 'Item Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter item price';
                final n = double.tryParse(val);
                if (n == null || n < 0) return 'Enter valid price';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Remove this item',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
