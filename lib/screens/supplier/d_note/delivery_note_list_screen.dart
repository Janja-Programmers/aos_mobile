import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/d_note/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import 'widgets/card_row.dart';

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
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      scaffoldKey: _scaffoldKey,
      subTitle: const Text(
        'Delivery Note',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: Consumer<DeliveryNoteProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            );
          }

          if (provider.failure != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error: ${provider.failure!.message}',
                    style: const TextStyle(color: Colors.red),
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

          if (provider.notes.isEmpty) {
            return const Center(child: Text('No delivery notes found.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                elevation: 2,
                child: Column(
                  children:
                      provider.notes.map((note) {
                        return Column(
                          children: [
                            DeliveryNoteCardRow(note: note),
                            const Divider(height: 2),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
