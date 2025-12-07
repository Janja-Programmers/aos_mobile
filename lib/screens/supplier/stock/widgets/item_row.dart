import 'package:flutter/material.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

import '../controllers/item_row_controller.dart';

import 'item_dropdown_field.dart';

import '/shared/widgets/form_fields.dart';

class ItemRow extends StatefulWidget {
  final ItemRowController controller;
  final VoidCallback? onRemove;
  final List<String> usedItemCodes;
  final bool? readOnly;

  const ItemRow({
    super.key,
    required this.controller,
    this.onRemove,
    this.readOnly,
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
        'https://africaonlinestores.com/api/resource/Product',
        queryParameters: {
          'fields': '["item_code", "item_name"]',
          'limit_page_length': 100,
          'filters': '[["is_stock_item", "=", 1]]',
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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = widget.controller.itemCode.text;
    final availableCodes =
        _itemCodes.where((code) {
          return code == currentCode || !widget.usedItemCodes.contains(code);
        }).toList();

    final readOnly = widget.readOnly ?? false;

    return Form(
      key: widget.controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemDropdownField(
            currentCode: widget.controller.itemCode.text,
            itemsMap: _itemsMap,
            availableCodes: availableCodes,
            label: 'Product',
            isRequired: true,
            readOnly: widget.readOnly ?? false,
            onChanged: (val) {
              widget.controller.itemCode.text = val!;
              widget.controller.itemName.text = _itemsMap[val] ?? '';
            },
          ),

          const SizedBox(height: 10),

          // ✅ Use AppTextField for consistency
          AppTextField(
            label: 'Quantity',
            controller: widget.controller.qty,
            maxLength: 10,
            isRequired: true,
            keyboardType: TextInputType.number,
            readOnly: readOnly,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Required field';
              final parsed = double.tryParse(val);
              if (parsed == null || parsed < 1) return 'Invalid quantity';
              return null;
            },
          ),

          const SizedBox(height: 10),

          // ✅ Use AppTextField again
          AppTextField(
            label: 'Valuation Rate (Optional)',
            controller: widget.controller.valuationRate,
            keyboardType: TextInputType.number,
            maxLength: 10,
            readOnly: readOnly,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return null;
              final parsed = double.tryParse(val);
              if (parsed == null || parsed < 0) return 'Invalid rate';
              return null;
            },
          ),

          if (widget.onRemove != null && !readOnly) ...[
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
