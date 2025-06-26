import 'package:flutter/material.dart';
import '../../../../features/item/domain/entity.dart';
import 'item_group_dropdown.dart';

class AddItemForm extends StatefulWidget {
  final int userId;
  final Future<void> Function(Item) onSubmit;

  const AddItemForm({super.key, required this.userId, required this.onSubmit});

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  String _selectedGroup = '';

  @override
  void dispose() {
    _itemCodeController.dispose();
    _itemNameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedGroup.isNotEmpty) {
      final newItem = Item(
        itemCode: _itemCodeController.text.trim(),
        name: _itemNameController.text.trim(),
        itemGroup: _selectedGroup,
      );
      await widget.onSubmit(newItem);
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() {}); // show validation errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            const Text(
              'Add New Item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _itemCodeController,
              decoration: const InputDecoration(labelText: 'Item Code'),
              textInputAction: TextInputAction.next,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              textInputAction: TextInputAction.next,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),

            ItemGroupDropdown(
              selectedGroup: _selectedGroup,
              onChanged: (val) {
                setState(() {
                  _selectedGroup = val;
                });
              },
            ),
            if (_selectedGroup.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Please select an item group',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            ElevatedButton(onPressed: _submit, child: const Text('Save Item')),
          ],
        ),
      ),
    );
  }
}
