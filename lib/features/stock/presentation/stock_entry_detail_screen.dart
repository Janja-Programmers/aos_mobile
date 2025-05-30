import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stock_provider.dart';

class StockEntryDetailScreen extends StatefulWidget {
  final int stockEntryId;

  const StockEntryDetailScreen({super.key, required this.stockEntryId});

  @override
  State<StockEntryDetailScreen> createState() => _StockEntryDetailScreenState();
}

class _StockEntryDetailScreenState extends State<StockEntryDetailScreen> {
  bool _hasTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<StockProvider>(context, listen: false);

    if (!_hasTriggered) {
      provider.fetchStockEntryDetail(widget.stockEntryId);
      _hasTriggered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final stockEntry = provider.stockEntryDetail;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (stockEntry == null) {
      return const Scaffold(body: Center(child: Text('Entry not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Entry Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile('Date', stockEntry.date.toIso8601String()),
            _buildInfoTile('Type', stockEntry.stockEntryType),
            _buildInfoTile('Company', stockEntry.company),
            _buildInfoTile('Target Warehouse', stockEntry.targetWarehouse),
            const SizedBox(height: 16),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: stockEntry.items.length,
                itemBuilder: (context, index) {
                  final item = stockEntry.items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.itemCode),
                      subtitle: Text(
                        'Qty: ${item.quantity} | Price: ${item.itemPrice}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
