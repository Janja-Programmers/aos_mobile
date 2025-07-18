import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/action_button.dart';

import '/features/stock/providers/create.dart';
import '/features/stock/domain/entity/stock.dart';

import 'controllers/item_row_controller.dart';
import 'widgets/item_row.dart';

class CreateStockEntryScreen extends StatefulWidget {
  final StockEntry? entry;
  const CreateStockEntryScreen({super.key, this.entry});

  @override
  State<CreateStockEntryScreen> createState() => _CreateStockEntryScreenState();
}

class _CreateStockEntryScreenState extends State<CreateStockEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final List<ItemRowController> _itemControllers = [ItemRowController()];

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateStockEntryProvider>().clearError();
    });

    if (isEditing) {
      for (final item in widget.entry!.items) {
        final controller = ItemRowController();
        controller.populateFromItem(item);
        _itemControllers.add(controller);
      }
      if (_itemControllers.length > 1) {
        _itemControllers.removeAt(0);
      }
    }
  }

  void _saveDraft() => _submitEntry(docstatus: 0);
  void _submitFinal() => _submitEntry(docstatus: 1);

  void _submitEntry({required int docstatus}) async {
    // ✅ 1. Validate item controllers
    bool allValid = true;
    for (final ctrl in _itemControllers) {
      if (!ctrl.validate()) allValid = false;
    }
    if (!allValid) return;

    // ✅ 2. Validate form
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        topSnackBar(
          context,
          'Please fix the form errors.',
          type: TopSnackType.error,
        );
      }
      return;
    }

    // ✅ 3. Ensure at least one item
    final items =
        _itemControllers
            .map((ctrl) => ctrl.entry)
            .where((item) => item.itemCode.isNotEmpty)
            .toList();

    if (items.isEmpty) {
      if (mounted) {
        topSnackBar(
          context,
          'Please add at least one product.',
          type: TopSnackType.error,
        );
      }
      return;
    }

    final entry = StockEntry(
      id: widget.entry?.id ?? '',
      docstatus: docstatus,
      items: items,
    );

    final provider = context.read<CreateStockEntryProvider>();

    if (isEditing) {
      await provider.update(entry);
    } else {
      await provider.submit(entry);
    }

    // ✅ 5. After submission, check UI still active
    if (!mounted) return;

    if (provider.hasError) {
      topSnackBar(context, "Unauthorized action", type: TopSnackType.error);
    } else {
      final action = docstatus == 1 ? 'submitted' : 'saved';
      topSnackBar(
        context,
        type: TopSnackType.success,
        'Stock Intake $action successfully',
      );
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      context.pop(true);
    }
  }

  @override
  void dispose() {
    for (final ctrl in _itemControllers) {
      ctrl.dispose();
    }
    context.read<CreateStockEntryProvider>().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateStockEntryProvider>();

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: Text(
        isEditing ? 'Edit Stock Intake' : 'Create Stock Intake',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _itemControllers.length,
              itemBuilder: (_, index) {
                final ctrl = _itemControllers[index];
                final usedCodes =
                    _itemControllers
                        .where((c) => c != ctrl)
                        .map((c) => c.itemCode.text)
                        .where((code) => code.isNotEmpty)
                        .toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ItemRow(
                        controller: ctrl,
                        usedItemCodes: usedCodes,
                        onRemove:
                            _itemControllers.length == 1
                                ? null
                                : () => setState(
                                  () => _itemControllers.removeAt(index),
                                ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                final usedCodes =
                    _itemControllers
                        .map((c) => c.itemCode.text)
                        .where((code) => code.isNotEmpty)
                        .toSet();

                if (usedCodes.length >= 100) {
                  if (mounted) {
                    topSnackBar(context, 'All products have been added');
                  }
                  return;
                }

                setState(() {
                  _itemControllers.add(ItemRowController());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Another entry'),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.loading ? null : _saveDraft,
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    label: provider.loading ? 'Submitting...' : 'Submit',
                    isLoading: provider.loading,
                    onPressed: _submitFinal,
                  ),
                ),
              ],
            ),
            if (provider.failure != null) ...[
              const SizedBox(height: 16),
              Text(
                "Unable to create entry",
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
