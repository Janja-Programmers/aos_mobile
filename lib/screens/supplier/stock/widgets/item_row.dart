import 'package:flutter/material.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

import '../controllers/item_row_controller.dart';

class ItemRow extends StatefulWidget {
  final ItemRowController controller;
  final VoidCallback? onRemove;
  final List<String> usedItemCodes;

  const ItemRow({
    super.key,
    required this.controller,
    this.onRemove,
    required this.usedItemCodes,
  });

  @override
  State<ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow> {
  List<String> _itemCodes = [];
  Map<String, String> _itemsMap = {};

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
        _itemsMap = {
          for (var e in items)
            e['item_code'] as String: e['item_name'] as String,
        };
      });
    } catch (e) {
      debugPrint('Failed to fetch item codes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = widget.controller.itemCode.text;
    final availableCodes =
        _itemCodes.where((code) {
          return code == currentCode || !widget.usedItemCodes.contains(code);
        }).toList();

    return Form(
      key: widget.controller.formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: currentCode.isEmpty ? null : currentCode,
            items:
                availableCodes.map((code) {
                  return DropdownMenuItem<String>(
                    value: code,
                    child: SizedBox(
                      height: 48,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _itemsMap[code] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            code,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

            selectedItemBuilder: (context) {
              return availableCodes.map((code) {
                return Text(
                  _itemsMap[code] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              }).toList();
            },

            onChanged:
                availableCodes.isEmpty
                    ? null // 🔒 Disable the dropdown
                    : (val) {
                      widget.controller.itemCode.text = val!;
                      widget.controller.itemName.text = _itemsMap[val] ?? '';
                    },

            decoration: InputDecoration(
              labelText: 'Item Code',
              hintText: availableCodes.isEmpty ? 'All items selected' : null,
            ),

            validator: (val) {
              if (availableCodes.isEmpty) {
                return null; // No items left to select
              }
              return val == null || val.isEmpty ? 'Required' : null;
            },
          ),

          const SizedBox(height: 10),

          TextFormField(
            controller: widget.controller.qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Required';
              final parsed = double.tryParse(val);
              if (parsed == null || parsed < 1) return 'Invalid quantity';
              return null;
            },
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: widget.controller.valuationRate,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Valuation Rate (Optional)',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return null;
              }
              final parsed = double.tryParse(val);
              if (parsed == null || parsed < 0) return 'Invalid rate';
              return null;
            },
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
      ),
    );
  }
}
