import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/item/domain/item.dart';
import '../item_provider.dart';
import '../widgets/item_form.dart';

class EditItemScreen extends StatelessWidget {
  final Item item;

  const EditItemScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ItemForm(
          initialItem: item,
          onSubmit: (updatedItem) async {
            await provider.updateItem(item.itemName, updatedItem);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Item updated')));
            }
          },
        ),
      ),
    );
  }
}
