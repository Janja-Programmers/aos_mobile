import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/item/domain/item.dart';
import '../item_provider.dart';
import '../widgets/item_form.dart';

class CreateItemScreen extends StatelessWidget {
  const CreateItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ItemForm(
          onSubmit: (Item newItem) async {
            await provider.addItem(newItem);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Item created')));
            }
          },
        ),
      ),
    );
  }
}
