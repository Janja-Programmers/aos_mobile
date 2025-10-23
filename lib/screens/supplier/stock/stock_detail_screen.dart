import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '/features/stock/providers/read.dart';
import '/screens/auth/auth_provider.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'utils/delete_stock_entry.dart';
import 'utils/failure_display.dart';
import 'utils/cancel_stock.dart';
import 'utils/print_stock_intake.dart';
import 'utils/submit_stock.dart';

import 'widgets/info_card.dart';
import 'widgets/info_table.dart';
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
    // Fetch stock entry on page load
    Future.microtask(() {
      context.read<StockEntryDetailProvider>().fetchById(widget.stockEntryName);
    });
  }

  Future<void> _refresh() async {
    await context.read<StockEntryDetailProvider>().fetchById(
      widget.stockEntryName,
    );
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
      subTitle: const Text(
        'Stock Intake',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actionButton: StockEntryActions(
        docstatus: entry.docstatus,
        onSubmit: () => submitStockEntry(context, entry),
        onCancel: () => cancelStockEntry(context, entry),
        onDelete: () => deleteStockEntry(context, entry.id),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (_) {
            if (prov.failure != null) {
              return FailureDisplay(failure: prov.failure!, onRetry: _refresh);
            }

            if (entry.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
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
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pull down to refresh or try again later.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Info Card
                StockEntryInfoCard(
                  entryId: entry.id,
                  docstatus: entry.docstatus,
                ),

                // Stock Table
                StockTableCard(entry: entry),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.white,
            child: const Icon(Icons.print),
            onPressed: () async {
              // ✅ safely read AuthProvider here (within the correct BuildContext)
              final username =
                  context.read<AuthProvider>().user?.username ?? 'Unknown User';
              topSnackBar(context, '🖨️ Printing...');

              // ✅ no Provider dependency inside the print function
              await printStockIntake(username: username, entry: entry);
            },
          );
        },
      ),
    );
  }
}
