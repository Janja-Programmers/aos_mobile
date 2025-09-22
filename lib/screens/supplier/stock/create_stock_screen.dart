import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/utils/snackbar.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';

import '/features/stock/providers/create.dart';
import '/features/stock/domain/entity/stock.dart';

import 'controllers/item_row_controller.dart';
import 'widgets/item_row.dart';
import 'widgets/stock_action_buttons.dart';

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

  late final CreateStockEntryProvider _provider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateStockEntryProvider>().clearError();
    });

    _provider = context.read<CreateStockEntryProvider>();

    if (isEditing) {
      for (final item in widget.entry!.items) {
        final controller = ItemRowController();
        controller.populateFromItem(item);
        _itemControllers.add(controller);
      }
      if (_itemControllers.length > 1) _itemControllers.removeAt(0);
    }
  }

  void _submitEntry({required int docstatus}) async {
    if (_itemControllers.any((ctrl) => !ctrl.validate())) return;

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
    await provider.saveOrSubmit(entry);

    if (!mounted) return;

    if (provider.hasError) {
      topSnackBar(context, "Unauthorized action", type: TopSnackType.error);
    } else {
      final action = docstatus == 1 ? 'submitted' : 'saved';
      topSnackBar(
        context,
        'Stock Intake $action successfully',
        type: TopSnackType.success,
      );
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) context.pop(true);
    }
  }

  @override
  void dispose() {
    for (final ctrl in _itemControllers) {
      ctrl.dispose();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.reset();
    });

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

      /// ✅ Top action button
      actionButton: StockActionButton(
        label:
            isEditing && provider.data?.docstatus == 0
                ? 'Submit'
                : 'Save Draft',
        onPressed:
            provider.loading
                ? null
                : () {
                  if (isEditing && provider.data?.docstatus == 0) {
                    _submitEntry(docstatus: 1);
                  } else {
                    _submitEntry(docstatus: 0);
                  }
                },
        isLoading: provider.loading,
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Item rows
            ..._itemControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final ctrl = entry.value;

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
            }),

            const SizedBox(height: 16),

            // Add another row button
            StockActionButton(
              label: 'Add Another Entry',
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

                setState(() => _itemControllers.add(ItemRowController()));
              },
            ),
          ],
        ),
      ),
      scaffoldKey: scaffoldKey,
    );
  }
}
