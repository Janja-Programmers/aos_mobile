import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'stock_provider.dart';
import 'widgets/stock_entry_card.dart';

class StockEntryListScreen extends StatelessWidget {
  const StockEntryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stockEntries = context.watch<StockProvider>().stockEntries;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Entries')),
      body:
          stockEntries.isEmpty
              ? const Center(child: Text('No stock entries found.'))
              : ListView.builder(
                itemCount: stockEntries.length,
                itemBuilder: (context, index) {
                  final entry = stockEntries[index];
                  return StockEntryCard(
                    stockEntry: entry,
                    onTap: () => context.push('/stock/${entry.id}'),
                  );
                },
              ),
    );
  }
}
