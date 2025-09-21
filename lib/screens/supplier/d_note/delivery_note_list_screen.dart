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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryNoteProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

          // 🔍 Filter notes by search query (customerName + status)
          final query = _searchController.text.trim().toLowerCase();
          final filteredNotes =
              provider.notes.where((note) {
                return query.isEmpty ||
                    note.customerName.toLowerCase().contains(query) ||
                    note.status.toLowerCase().contains(query);
              }).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  // 🔍 Search bar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search by customer or status',
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

                  // Notes list
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 2,
                    child: Column(
                      children:
                          filteredNotes.isEmpty
                              ? [
                                const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text(
                                    "No delivery notes match your search.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]
                              : filteredNotes
                                  .map(
                                    (note) => Column(
                                      children: [
                                        DeliveryNoteCardRow(note: note),
                                        const Divider(height: 2),
                                      ],
                                    ),
                                  )
                                  .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
