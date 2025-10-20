import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/features/invoice/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/empty_state.dart';
import '/shared/widgets/main_bar.dart';

import 'widgets/invoice_card_row.dart';

class SalesInvoiceListScreen extends StatefulWidget {
  const SalesInvoiceListScreen({super.key});

  @override
  State<SalesInvoiceListScreen> createState() => _SalesInvoiceListScreenState();
}

class _SalesInvoiceListScreenState extends State<SalesInvoiceListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SalesInvoiceProvider>().fetchAll(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<SalesInvoiceProvider>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 5, onItemSelected: (_) {}),
      subTitle: const Text(
        'Sales Invoices',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: Consumer<SalesInvoiceProvider>(
        builder: (context, provider, _) {
          // 🔄 Loading state
          if (provider.listLoading) {
            return const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            );
          }

          // ⚠️ Error state
          if (provider.failure != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Error: Could not load invoices',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _refresh,
                  ),
                ],
              ),
            );
          }

          // 🔎 Filter invoices by search query
          final query = _searchController.text.trim().toLowerCase();
          final filtered =
              provider.invoices.where((invoice) {
                return query.isEmpty ||
                    invoice.customerName.toLowerCase().contains(query) ||
                    invoice.status.toLowerCase().contains(query) ||
                    invoice.id.toLowerCase().contains(query);
              }).toList();

          // 📭 No invoices at all
          if (provider.invoices.isEmpty) {
            return const Center(child: Text('No sales invoices found.'));
          }

          // ✅ Main content
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // 🔍 Search bar
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by customer, ID, or status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                // 📋 List of invoices
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Header with counts
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Sales Invoices",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${filtered.length} of ${provider.invoices.length}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(
                          height: 0,
                          thickness: 1.2,
                          color: AppColors.background,
                        ),

                        // Body (list or empty state)
                        Expanded(
                          child:
                              filtered.isEmpty
                                  ? EmptyState(
                                    message:
                                        'No sales invoice matches your search.',
                                    actionLabel: 'Clear search',
                                    onAction: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                  : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: filtered.length,
                                    separatorBuilder:
                                        (_, _) => const Divider(
                                          height: 0.5,
                                          thickness: 0.5,
                                        ),
                                    itemBuilder: (_, i) {
                                      final invoice = filtered[i];
                                      return SalesInvoiceCardRow(
                                        invoice: invoice,
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
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
