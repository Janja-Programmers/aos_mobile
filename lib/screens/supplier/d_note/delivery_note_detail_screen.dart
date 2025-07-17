import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/d_note/prov.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import '/core/utils/snackbar.dart';
import 'utils/print_note.dart';

class DeliveryNoteDetailScreen extends StatefulWidget {
  final String noteId;
  const DeliveryNoteDetailScreen({super.key, required this.noteId});

  @override
  State<DeliveryNoteDetailScreen> createState() =>
      _DeliveryNoteDetailScreenState();
}

class _DeliveryNoteDetailScreenState extends State<DeliveryNoteDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeliveryNoteProvider>().fetchById(widget.noteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final provider = context.watch<DeliveryNoteProvider>();
    final note = provider.selectedNote;

    return MainBarScaffold(
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      subTitle: Text('Delivery Note Detail'),
      scaffoldKey: scaffoldKey,
      body: Builder(
        builder: (_) {
          if (provider.loading || note == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.customerName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(label: Text(note.status)),
                    const SizedBox(width: 12),
                    Text(
                      'ID: ${note.id}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoTile(
                      'Total',
                      'Sh ${note.grandTotal.toStringAsFixed(2)}',
                    ),
                    _infoTile('% Installed', '${note.percentInstalled}%'),
                  ],
                ),

                const SizedBox(height: 24),

                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),

                ...note.items.map((item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.itemName} (${item.itemCode})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _itemMeta('Qty', item.qty.toStringAsFixed(0)),
                              _itemMeta('Rate', item.rate.toStringAsFixed(2)),
                              _itemMeta(
                                'Amount',
                                item.amount.toStringAsFixed(2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    topSnackBar(context, 'Printing...');
                    await printDeliveryNote(note);
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _itemMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
