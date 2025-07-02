import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/stock/providers/read.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'utils/failure_display.dart';
import 'utils/submit_stock.dart';

import 'widgets/item_tile.dart';
import 'widgets/stock_detail_header.dart';

class StockEntryDetailScreen extends StatefulWidget {
  final String stockEntryName;

  const StockEntryDetailScreen({super.key, required this.stockEntryName});

  @override
  State<StockEntryDetailScreen> createState() => _StockEntryDetailScreenState();
}

class _StockEntryDetailScreenState extends State<StockEntryDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<StockEntryDetailProvider>().fetchById(
        widget.stockEntryName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockEntryDetailProvider>();

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: 'Stock Entry Detail',
      body: Builder(
        builder: (_) {
          if (prov.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.failure != null) {
            return FailureDisplay(
              failure: prov.failure!,
              onRetry:
                  () => context.read<StockEntryDetailProvider>().fetchById(
                    widget.stockEntryName,
                  ),
            );
          }

          final entry = prov.data;
          if (entry == null) {
            return const Center(child: Text('Entry not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StockDetailHeader(entry: entry),
                const SizedBox(height: 16),
                if (entry.docstatus == 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => submitStockEntry(context, entry),
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Entry'),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: entry.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => StockItemTile(item: entry.items[i]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
