import 'package:flutter/material.dart';

import '/features/itemPrice/domain/item_price.dart';

class AddItemPriceModal extends StatefulWidget {
  const AddItemPriceModal({super.key});

  @override
  State<AddItemPriceModal> createState() => _AddItemPriceModalState();
}

class _AddItemPriceModalState extends State<AddItemPriceModal> {
  final _formKey = GlobalKey<FormState>();
  final _itemCode = TextEditingController();
  final _uom = TextEditingController(text: 'Nos');
  final _priceList = TextEditingController(text: 'Standard Selling');
  final _rate = TextEditingController();

  @override
  void dispose() {
    _itemCode.dispose();
    _uom.dispose();
    _priceList.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final rateText = _rate.text.trim();
      final entity = ItemPrice(
        itemCode: _itemCode.text.trim(),
        uom: _uom.text.trim(),
        priceList: _priceList.text.trim(),
        priceListRate: rateText.isEmpty ? null : double.parse(rateText),
      );
      Navigator.pop<ItemPrice>(context, entity); // ⬅️ return value
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom, left: 16, right: 16, top: 24),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            const Center(
              child: Text(
                'New Item Price',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _itemCode,
              decoration: const InputDecoration(
                labelText: 'Item Code',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _uom,
              decoration: const InputDecoration(
                labelText: 'UOM',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            TextFormField(
              controller: _priceList,
              decoration: const InputDecoration(
                labelText: 'Price List',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            TextFormField(
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Rate (KES)',
                border: OutlineInputBorder(),
              ),
              // ✅ allow empty
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null; // optional
                return double.tryParse(v) == null ? 'Enter a number' : null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
