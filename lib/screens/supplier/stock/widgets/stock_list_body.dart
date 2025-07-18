import 'package:flutter/material.dart';
import 'package:ownashop/core/constants/colors.dart';
import 'package:provider/provider.dart';

import '/features/stock/providers/all.dart';
import '../utils/failure_display.dart';
import 'stock_list_tile.dart';

class StockListBody extends StatelessWidget {
  const StockListBody({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockEntryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: prov.fetchAll,
          child: Builder(
            builder: (_) {
              if (prov.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (prov.failure != null) {
                return FailureDisplay(
                  failure: prov.failure!,
                  onRetry: prov.fetchAll,
                );
              }

              final vendorEntries = prov.entries.toList();

              if (vendorEntries.isEmpty) {
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
                        'No stock entries found',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: vendorEntries.length,
                    separatorBuilder: (_, _) => const Divider(height: 0),
                    itemBuilder: (_, i) {
                      final entry = vendorEntries[i];
                      return StockListTile(
                        id: entry.id,
                        docstatus: entry.docstatus,
                        date: entry.modified!.toIso8601String(),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
