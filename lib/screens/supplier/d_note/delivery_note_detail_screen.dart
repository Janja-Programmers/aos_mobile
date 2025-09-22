import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';

import '/features/d_note/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';

import 'utils/print_note.dart';

import 'widgets/detail_card.dart';
import 'widgets/item_card.dart';

class DeliveryNoteDetailScreen extends StatefulWidget {
  final String noteId;
  const DeliveryNoteDetailScreen({super.key, required this.noteId});

  @override
  State<DeliveryNoteDetailScreen> createState() =>
      _DeliveryNoteDetailScreenState();
}

class _DeliveryNoteDetailScreenState extends State<DeliveryNoteDetailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeliveryNoteProvider>().fetchById(widget.noteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryNoteProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.failure != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Error: ${provider.failure!.message}",
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () {
                provider.fetchById(widget.noteId);
              },
            ),
          ],
        ),
      );
    }

    final note = provider.selectedNote;
    if (note == null) {
      return const Center(child: Text("Delivery note not found"));
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      subTitle: const Text(
        'Delivery Note',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      actionButton: IconButton(
        icon: const Icon(Icons.print),
        onPressed: () async {
          topSnackBar(context, 'Printing...');
          await printDeliveryNote(note);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DetailCard(
              title: note.customerName,
              subtitle: note.id,
              status: note.status,
            ),

            const SizedBox(height: 16),
            ItemsCard(note: note),
          ],
        ),
      ),
    );
  }
}
