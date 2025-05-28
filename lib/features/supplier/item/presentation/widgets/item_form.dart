import 'package:flutter/material.dart';

import '../../../../shared/item/domain/item.dart';
import 'item_group_dropdown.dart';

class ItemForm extends StatefulWidget {
  final void Function(Item item) onSubmit;
  final Item? initialItem; // For edit mode

  const ItemForm({super.key, required this.onSubmit, this.initialItem});

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _itemNameController;
  late TextEditingController _companyController;

  String itemGroup = '';

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(
      text: widget.initialItem?.itemName ?? '',
    );
    itemGroup = widget.initialItem?.itemGroup ?? '';
    _companyController = TextEditingController(
      text: widget.initialItem?.company ?? 'Ownashop',
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final item = Item(
        itemName: _itemNameController.text.trim(),
        itemGroup: itemGroup,
        company: _companyController.text.trim(),
        createdBy: 'seller123', // Replace with actual logged-in user
      );

      widget.onSubmit(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _itemNameController,
            decoration: const InputDecoration(labelText: 'Item Name'),
            validator:
                (value) => value == null || value.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          ItemGroupDropdown(
            selectedGroup: itemGroup,
            onChanged: (val) => setState(() => itemGroup = val),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _companyController,
            decoration: const InputDecoration(labelText: 'Company'),
            readOnly: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.initialItem == null ? 'Create Item' : 'Update'),
          ),
        ],
      ),
    );
  }
}
