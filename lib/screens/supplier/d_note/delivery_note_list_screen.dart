// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/d_note/prov.dart';
import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import 'widgets/note_tile.dart';

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
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
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
                return DeliveryNoteTile(note: note);
              },
            ),
          );
        },
      ),
    );
  }
}
