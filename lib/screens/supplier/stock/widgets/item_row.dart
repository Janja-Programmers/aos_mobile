import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/product/provider.dart';
import '/features/stock/domain/entity/stock_item.dart';

class ItemRow extends StatefulWidget {
  final void Function()? onRemove;
  final void Function()? onChanged;

  const ItemRow({super.key, this.onRemove, this.onChanged});

  @override
  State<ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow> {
  final _itemCodeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();

  @override
  void dispose() {
    _itemCodeController.dispose();
    _itemNameController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  StockEntryItem toEntryItem() {
    return StockEntryItem(
      itemCode: _itemCodeController.text,
      itemName: _itemNameController.text,
      qty: double.tryParse(_qtyController.text) ?? 0,
      valuationRate: double.tryParse(_rateController.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProv = context.read<ProductProvider>();
    final items = itemProv.products;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value:
                  _itemCodeController.text.isNotEmpty
                      ? _itemCodeController.text
                      : null,
              items:
                  items
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.name,
                          child: Text(e.itemName),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                final selected = items.firstWhere((e) => e.name == val);
                _itemCodeController.text = selected.name;
                _itemNameController.text = selected.itemName;
                if (widget.onChanged != null) widget.onChanged!();
                setState(() {});
              },
              decoration: const InputDecoration(labelText: 'Item Code'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _itemNameController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valuation Rate',
                    ),
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  StockEntryItem get entry => toEntryItem();
}
