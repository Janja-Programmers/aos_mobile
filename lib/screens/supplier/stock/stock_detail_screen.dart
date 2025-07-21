import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '/features/stock/providers/read.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/build_subtitle.dart';
import '/shared/widgets/main_bar.dart';

import 'utils/delete_stock_entry.dart';
import 'utils/failure_display.dart';
import 'utils/cancel_stock.dart';
import 'utils/print_stock_entry.dart';
import 'utils/reload_stock.dart';
import 'utils/submit_stock.dart';

import 'widgets/stock_entry_actions.dart';

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
    Future.microtask(() {
      context.read<StockEntryDetailProvider>().fetchById(widget.stockEntryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockEntryDetailProvider>();
    final entry = prov.data;

    if (prov.loading || entry == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 2, onItemSelected: (_) {}),
      subTitle: buildSubTitle(title: entry.id, docstatus: entry.docstatus),
      actionButton: StockEntryActions(
        docstatus: entry.docstatus,
        onSubmit: () => submitStockEntry(context, entry),
        onCancel: () => cancelStockEntry(context, entry),
        onReload: () => reloadStockEntry(context, entry),
        onPrint: () => printStockIntake(context, entry),
        onDelete: () => deleteStockEntry(context, entry.id),
      ),
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

          if (entry.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh or try again later.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(6),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // List Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const Divider(
                    height: 0,
                    thickness: 1.2,
                    color: AppColors.background,
                  ),

                  Expanded(
                    child:
                        entry.items.isEmpty
                            ? const Center(
                              child: Text('No items found in this entry.'),
                            )
                            : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: entry.items.length,
                              separatorBuilder:
                                  (_, _) => const SizedBox(height: 8),
                              itemBuilder:
                                  (_, i) => ListTile(
                                    title: Text(
                                      entry.items[i].itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Qty: ${entry.items[i].qty}   Rate: ${entry.items[i].valuationRate}',
                                    ),
                                    trailing: Text(
                                      'Total: ${entry.items[i].totalValue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
