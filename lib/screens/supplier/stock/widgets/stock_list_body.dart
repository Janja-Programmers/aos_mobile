import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/stock/providers/all.dart';
import '../utils/failure_display.dart';

import 'stock_card.dart';

class StockListBody extends StatelessWidget {
  const StockListBody({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockEntryProvider>();

    return RefreshIndicator(
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

          if (prov.names.isEmpty) {
            return const Center(child: Text('No stock entriese found.'));
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: prov.names.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => StockCard(name: prov.names[i]),
          );
        },
      ),
    );
  }
}
