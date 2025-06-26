import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/stock/domain/stock_entry.dart';
import '/features/stock/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'failure_display.dart';

class StockEntryScreen extends StatefulWidget {
  const StockEntryScreen({super.key});

  @override
  State<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends State<StockEntryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StockEntryProvider>().fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockEntryProvider>();

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 3, onItemSelected: (_) {}),
      subTitle: 'Stock Entry List',
      scaffoldKey: _scaffoldKey,
      body: RefreshIndicator(
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

            if (prov.entries.isEmpty) {
              return const Center(child: Text('No stock entries found.'));
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: prov.entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final entry = prov.entries[i];
                return _StockEntryCard(entry: entry);
              },
            );
          },
        ),
      ),
    );
  }
}

class _StockEntryCard extends StatelessWidget {
  final StockEntry entry;
  const _StockEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isApproved = entry.status == "1";
    final statusColor = isApproved ? Colors.green : Colors.orange;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.id,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _InfoChip(
                  icon: Icons.category,
                  label: entry.stockEntryType,
                  color: Colors.blue.shade100,
                ),
                _InfoChip(
                  icon: Icons.sync_alt,
                  label: entry.purpose,
                  color: Colors.teal.shade100,
                ),
                _InfoChip(
                  icon: Icons.warehouse,
                  label: entry.sourceWarehouse,
                  color: Colors.purple.shade100,
                ),
                Chip(
                  label: Text(
                    isApproved ? 'Approved' : 'Pending',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  // ignore: deprecated_member_use
                  backgroundColor: statusColor.withOpacity(0.2),
                  avatar: Icon(
                    isApproved ? Icons.check_circle : Icons.hourglass_empty,
                    color: statusColor,
                  ),
                  shape: StadiumBorder(side: BorderSide(color: statusColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.black54),
      label: Text(label),
      backgroundColor: color,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
