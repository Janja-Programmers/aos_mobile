import 'package:flutter/material.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

import '../controllers/item_row_controller.dart';

class ItemRow extends StatefulWidget {
  final ItemRowController controller;
  final VoidCallback? onRemove;

  const ItemRow({super.key, required this.controller, this.onRemove});

  @override
  State<ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow> {
  List<String> _itemCodes = [];

  @override
  void initState() {
    super.initState();
    _fetchItemCodes();
  }

  Future<void> _fetchItemCodes() async {
    try {
      final res = await sl<APIClient>().client.get(
        'https://ownashop.com/api/resource/Product',
        queryParameters: {
          'fields': '["item_code", "item_name"]',
          'limit_page_length': 100,
        },
      );

      final items = res.data['data'] as List;
      setState(() {
        _itemCodes = items.map((e) => e['item_code'] as String).toList();
        _itemsMap = {for (var e in items) e['item_code']: e['item_name']};
      });
    } catch (e) {
      debugPrint('Failed to fetch item codes: $e');
    }
  }

  Map<String, String> _itemsMap = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value:
              widget.controller.itemCode.text.isEmpty
                  ? null
                  : widget.controller.itemCode.text,
          items:
              _itemCodes.map((code) {
                return DropdownMenuItem(value: code, child: Text(code));
              }).toList(),
          onChanged: (val) {
            widget.controller.itemCode.text = val!;
            widget.controller.itemName.text = _itemsMap[val] ?? '';
          },
          decoration: const InputDecoration(labelText: 'Item Code'),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 10),

        TextFormField(
          controller: widget.controller.itemName,
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Item Name'),
        ),
        const SizedBox(height: 10),

        TextFormField(
          controller: widget.controller.qty,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity'),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 10),

        TextFormField(
          controller: widget.controller.valuationRate,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Valuation Rate'),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),

        if (widget.onRemove != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            label: const Text('Remove Item'),
          ),
        ],
      ],
    );
  }
}
