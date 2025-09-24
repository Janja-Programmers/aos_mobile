import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '/shared/utils/doc_status.dart';
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
    _provider = context.read<CreateStockEntryProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.clearError();
    });

    if (isEditing) {
      for (final item in widget.entry!.items) {
        final controller = ItemRowController();
        controller.populateFromItem(item);
        _itemControllers.add(controller);
      }
      if (_itemControllers.length > 1) _itemControllers.removeAt(0);
    }
  }

  Future<void> _submitEntry({required bool submit}) async {
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
      docstatus: widget.entry?.docstatus ?? DocStatus.draft,
      items: items,
    );

    final provider = context.read<CreateStockEntryProvider>();
    await provider.saveOrSubmit(entry, submit: submit);

    if (!mounted) return;

    if (provider.hasError) {
      topSnackBar(
        context,
        provider.errorMessage ?? "Something went wrong",
        type: TopSnackType.error,
      );
    } else {
      final action = submit ? 'submitted' : 'saved';
      topSnackBar(
        context,
        'Stock Intake $action successfully',
        type: TopSnackType.success,
      );

      final savedEntry = provider.data;
      if (savedEntry != null && savedEntry.id.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          context.push('/stock-entry/${savedEntry.id}');
        }
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _itemControllers) {
      ctrl.dispose();
    }
    _provider.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateStockEntryProvider>();
    final isReadOnly = provider.isSubmitted;

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: Text(
        isEditing ? 'Edit Stock Intake' : 'Create Stock Intake',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      /// ✅ Top action button
      actionButton:
          isReadOnly
              ? null
              : StockActionButton(
                label: isEditing && provider.isDraft ? 'Submit' : 'Save',
                onPressed:
                    provider.loading
                        ? null
                        : () {
                          final submit = isEditing && provider.isDraft;
                          _submitEntry(submit: submit);
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
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ItemRow(
                      controller: ctrl,
                      usedItemCodes: usedCodes,
                      readOnly: isReadOnly,
                      onRemove:
                          isReadOnly || _itemControllers.length == 1
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
            if (!isReadOnly)
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
