import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/constants/colors.dart';

import '/features/d_note/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/empty_state.dart';

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
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      subTitle: const Text(
        'Delivery Notes',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      body: Consumer<DeliveryNoteProvider>(
        builder: (context, provider, _) {
          if (provider.listLoading) {
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

          final query = _searchController.text.trim().toLowerCase();
          final filteredNotes =
              provider.notes.where((note) {
                return query.isEmpty ||
                    note.customerName.toLowerCase().contains(query) ||
                    note.status.toLowerCase().contains(query) ||
                    note.id.toLowerCase().contains(query);
              }).toList();

          if (provider.notes.isEmpty) {
            return const Center(child: Text('No delivery notes found.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
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

                // List card
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
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Delivery Notes",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${filteredNotes.length} of ${provider.notes.length}",
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

                        // List
                        Expanded(
                          child:
                              filteredNotes.isEmpty
                                  ? EmptyState(
                                    message:
                                        'No delivery notes match your search.',
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
                                    itemCount: filteredNotes.length,
                                    separatorBuilder:
                                        (_, __) => const Divider(
                                          height: 0.5,
                                          thickness: 0.5,
                                        ),
                                    itemBuilder: (_, i) {
                                      final note = filteredNotes[i];
                                      return InkWell(
                                        onTap:
                                            () => context.push(
                                              '/delivery-note/${note.id}',
                                            ),
                                        child: DeliveryNoteCardRow(note: note),
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
