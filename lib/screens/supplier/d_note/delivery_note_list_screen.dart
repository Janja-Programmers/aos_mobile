import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/d_note/prov.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

class DeliveryNoteListScreen extends StatefulWidget {
  const DeliveryNoteListScreen({super.key});

  @override
  State<DeliveryNoteListScreen> createState() => _DeliveryNoteListScreenState();
}

class _DeliveryNoteListScreenState extends State<DeliveryNoteListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryNoteProvider>().fetchAll();
    });
  }

  Future<void> _refresh() async {
    await context.read<DeliveryNoteProvider>().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return MainBarScaffold(
      subTitle: 'Delivery Notes',
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 6, onItemSelected: (_) {}),
      body: Consumer<DeliveryNoteProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.failure != null) {
            return Center(
              child: Text(
                'Error: ${provider.failure!.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.notes.isEmpty) {
            return const Center(child: Text('No delivery notes found.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: provider.notes.length,
              itemBuilder: (context, index) {
                final note = provider.notes[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.customerName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _statusChip(note.status),
                            const SizedBox(width: 10),
                            Text(
                              'ID: ${note.id}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoTile(
                              'Total',
                              note.grandTotal.toStringAsFixed(2),
                            ),
                            _infoTile(
                              '% Installed',
                              '${note.percentInstalled}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status.toLowerCase()) {
      'completed' => Colors.green,
      'pending' => Colors.orange,
      _ => Colors.blue,
    };

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
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
}
