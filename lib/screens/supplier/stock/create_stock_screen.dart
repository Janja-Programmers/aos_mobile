import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '/shared/utils/doc_status.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/app_drawer.dart';

import '/features/stock/providers/all.dart';
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

  late final CreateStockEntryProvider _provider;
  late bool _isEditing;
  StockEntry? _savedEntry;

  @override
  void initState() {
    super.initState();
    _provider = context.read<CreateStockEntryProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.clearError();
    });

    _isEditing = widget.entry != null;
    _savedEntry = widget.entry;

    if (_isEditing) {
      for (final item in widget.entry!.items) {
        final controller = ItemRowController();
        controller.populateFromItem(item);
        _itemControllers.add(controller);
      }
      if (_itemControllers.length > 1) _itemControllers.removeAt(0);
    }
  }

  Future<void> _submitEntry({required bool submit}) async {
    // 1️⃣ Validate form
    if (_itemControllers.any((ctrl) => !ctrl.validate())) return;
    if (!_formKey.currentState!.validate()) {
      topSnackBar(
        context,
        'Please fix the form errors.',
        type: TopSnackType.error,
      );
      return;
    }

    // 2️⃣ Collect items
    final items =
        _itemControllers
            .map((ctrl) => ctrl.entry)
            .where((item) => item.itemCode.isNotEmpty)
            .toList();

    if (items.isEmpty) {
      topSnackBar(
        context,
        'Please add at least one product.',
        type: TopSnackType.error,
      );
      return;
    }

    // 3️⃣ Build entry
    final entry = StockEntry(
      id: _savedEntry?.id ?? '',
      docstatus: _savedEntry?.docstatus ?? DocStatus.draft,
      items: items,
    );

    // 4️⃣ Save or submit via provider
    final provider = context.read<CreateStockEntryProvider>();
    await provider.saveOrSubmit(entry, submit: submit);

    if (!mounted) return;

    // 5️⃣ Handle result
    if (provider.hasError) {
      topSnackBar(
        context,
        provider.errorMessage ?? "Something went wrong",
        type: TopSnackType.error,
      );
      return;
    }

    final savedEntry = provider.data;
    if (savedEntry == null) return;

    // ✅ Update local state to editing mode
    if (!_isEditing) {
      setState(() {
        _isEditing = true;
        _savedEntry = savedEntry;
      });
    } else {
      _savedEntry = savedEntry;
    }

    // 6️⃣ Show feedback
    topSnackBar(
      context,
      submit
          ? 'Stock Intake submitted successfully'
          : 'Draft saved! You can now submit.',
      type: TopSnackType.success,
    );

    // 7️⃣ Refresh list only if submitting or editing
    if (_isEditing || submit) {
      await context.read<StockEntryProvider>().fetchAll();
      if (submit) context.pop();
    }
  }

  @override
  void dispose() {
    for (final ctrl in _itemControllers) {
      ctrl.dispose();
    }
    _provider.resetSilently();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateStockEntryProvider>();
    final isReadOnly = provider.isSubmitted;

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: Text(
        _isEditing ? 'Edit Stock Intake' : 'Create Stock Intake',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      /// ✅ Top action button
      actionButton:
          isReadOnly
              ? null
              : StockActionButton(
                label: _isEditing ? 'Submit' : 'Save',
                onPressed:
                    provider.loading
                        ? null
                        : () {
                          _submitEntry(submit: _isEditing);
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
