import 'package:flutter/material.dart';
import 'package:ownashop/screens/supplier/stock/controllers/item_row_controller.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/di/service_locator.dart';
import '/core/utils/snackbar.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/action_button.dart';

import '/features/stock/providers/create.dart';
import '/features/stock/domain/entity/stock.dart';
import '/features/stock/domain/entity/stock_item.dart';

/**************************************************************************************************************************************
 * ERRORS IN FILE
 * 
 * 
 * ** */

import 'widgets/item_row.dart';
import 'widgets/item_row.dart';

class CreateStockEntryScreen extends StatefulWidget {
  const CreateStockEntryScreen({super.key});

  @override
  State<CreateStockEntryScreen> createState() => _CreateStockEntryScreenState();
}

class _CreateStockEntryScreenState extends State<CreateStockEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final List<ItemRowController> _itemControllers = [ItemRowController()];

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      topSnackBar(
        context,
        'Please fix the form errors.',
        type: TopSnackType.error,
      );
      return;
    }

    final provider = context.read<CreateStockEntryProvider>();

    // final items = _itemControllers.map((ctrl) => ctrl.toEntryItem()).toList();
    final items = [
      {"item": "12", "quantity": 12, "rate": 12.10, "amount": 120},
    ];

    final entry = StockEntry(
      id: '',
      docstatus: 0,
      vendor: '', // will be set by backend
      items: items as List<StockEntryItem>,
    );

    await provider.submit(entry);

    if (!mounted) return;

    if (provider.hasError) {
      topSnackBar(context, provider.failure!.message, type: TopSnackType.error);
    } else {
      topSnackBar(context, 'Stock Entry submitted');
      context.pop();
    }
  }

  @override
  void dispose() {
    for (final ctrl in _itemControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateStockEntryProvider>();

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: 'Create Stock Entry',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._itemControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ItemRow(
                  onRemove:
                      _itemControllers.length == 1
                          ? null
                          : () =>
                              setState(() => _itemControllers.removeAt(index)),
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _itemControllers.add(ItemRowController()));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: provider.loading ? 'Submitting...' : 'Submit Entry',
              isLoading: provider.loading,
              onPressed: _submit,
            ),
            if (provider.failure != null) ...[
              const SizedBox(height: 16),
              Text(
                provider.failure!.message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      scaffoldKey: scaffoldKey,
    );
  }
}
