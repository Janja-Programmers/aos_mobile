import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_provider.dart';
import '../domain/entities/stock_entry.dart';
import '../domain/entities/stock_item.dart';
import 'stock_provider.dart';
import 'widgets/stock_item_form.dart';
import 'widgets/stock_item_form_data.dart';

class StockEntryFormScreen extends StatefulWidget {
  const StockEntryFormScreen({super.key});

  @override
  State<StockEntryFormScreen> createState() => _StockEntryFormScreenState();
}

class _StockEntryFormScreenState extends State<StockEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  String _company = 'Ownashop';
  String _stockEntryType = 'Material Receipt';
  String _targetWarehouse = 'Stores';

  final List<StockItemFormData> _stockItems = [];

  @override
  void initState() {
    super.initState();
    _stockItems.add(StockItemFormData());
  }

  @override
  void dispose() {
    for (final item in _stockItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addStockItem() {
    setState(() {
      _stockItems.add(StockItemFormData());
    });
  }

  void _removeStockItem(int index) {
    setState(() {
      _stockItems[index].dispose();
      _stockItems.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_stockItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Add at least one stock item')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id ?? 0;

    // Delay heavy object creation to microtask
    await Future.microtask(() {
      final stockItems =
          _stockItems.map((item) {
            return StockItem(
              id: 0,
              targetWarehouse: _targetWarehouse,
              itemCode: item.itemCodeController.text.trim(),
              quantity: int.tryParse(item.quantityController.text) ?? 0,
              itemPrice: double.tryParse(item.itemPriceController.text) ?? 0.0,
            );
          }).toList();

      final stockEntry = StockEntry(
        id: 0,
        date: _selectedDate,
        company: _company,
        stockEntryType: _stockEntryType,
        targetWarehouse: _targetWarehouse,
        createdBy: userId,
        items: stockItems,
      );

      context.read<StockProvider>().addStockEntry(stockEntry);
    });

    final stockProvider = context.read<StockProvider>();
    if (stockProvider.error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(stockProvider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Stock Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(
                'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _company,
              items:
                  ['Ownashop']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (val) => setState(() => _company = val!),
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            DropdownButtonFormField<String>(
              value: _stockEntryType,
              items:
                  ['Material Receipt', 'Material Issue']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _stockEntryType = val!),
              decoration: const InputDecoration(labelText: 'Stock Entry Type'),
            ),
            DropdownButtonFormField<String>(
              value: _targetWarehouse,
              items:
                  ['Stores', 'Warehouse A', 'Warehouse B']
                      .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                      .toList(),
              onChanged: (val) => setState(() => _targetWarehouse = val!),
              decoration: const InputDecoration(labelText: 'Target Warehouse'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Stock Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              itemCount: _stockItems.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = _stockItems[index];
                return StockItemForm(
                  key: ValueKey(index),
                  data: data,
                  onRemove: () => _removeStockItem(index),
                );
              },
            ),

            ElevatedButton.icon(
              onPressed: _addStockItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Stock Item'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Save Stock Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
