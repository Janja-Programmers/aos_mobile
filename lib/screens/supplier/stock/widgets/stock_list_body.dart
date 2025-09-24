import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';
import '/features/stock/providers/all.dart';
import '/shared/widgets/empty_state.dart';

import 'stock_list_tile.dart';

class StockListBody extends StatefulWidget {
  const StockListBody({super.key});

  @override
  State<StockListBody> createState() => _StockListBodyState();
}

class _StockListBodyState extends State<StockListBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockEntryProvider>();

    final query = _searchController.text.trim().toLowerCase();
    final filteredEntries =
        prov.entries.where((entry) {
          return query.isEmpty || entry.id.toLowerCase().contains(query);
        }).toList();

    Widget content;

    if (prov.loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (prov.failure != null) {
      content = Text(
        "Failed to load entries",
        style: TextStyle(color: Colors.red),
      );
    } else if (prov.entries.isEmpty) {
      // No stock entries at all
      content = const EmptyState(message: 'No stock entries found.');
    } else {
      // Normal state with search + list
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search stock entries by ID',
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

          // Card list
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // List Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Stock Entries",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${filteredEntries.length} of ${prov.entries.length}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 0,
                    thickness: 1.2,
                    color: AppColors.background,
                  ),

                  // The list itself
                  Expanded(
                    child:
                        filteredEntries.isEmpty
                            ? EmptyState(
                              message: 'No stock entries match your search.',
                              actionLabel: 'Clear search',
                              onAction: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                            : RefreshIndicator(
                              onRefresh: prov.fetchAll,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: filteredEntries.length,
                                separatorBuilder:
                                    (_, __) => const Divider(
                                      height: 0.5,
                                      thickness: 0.5,
                                    ),
                                itemBuilder: (_, i) {
                                  final entry = filteredEntries[i];
                                  return StockListTile(
                                    id: entry.id,
                                    docstatus: entry.docstatus,
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(top: false, child: content),
    );
  }
}
