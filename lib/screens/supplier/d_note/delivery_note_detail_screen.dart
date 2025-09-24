import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/utils/snackbar.dart';
import '/features/d_note/prov.dart';

import '/shared/widgets/app_drawer.dart';
import '/shared/widgets/main_bar.dart';
import '/shared/widgets/empty_state.dart';

import 'widgets/detail_card.dart';
import 'widgets/item_card.dart';
import 'utils/print_note.dart';

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
    final note = provider.selectedNote;

    Widget body;

    if (provider.detailLoading) {
      body = const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    } else if (note == null) {
      body = const EmptyState(message: "Error: Delivery note not found");
    } else {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ListView(
          children: [
            DetailCard(
              title: note.customerName,
              subtitle: note.id,
              status: note.status,
            ),
            ItemsCard(note: note),
          ],
        ),
      );
    }

    return MainBarScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: AppDrawer(selectedIndex: 4, onItemSelected: (_) {}),
      subTitle: const Text(
        'Delivery Note',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      actionButton: null,
      body: body,
      floatingActionButton:
          note != null
              ? FloatingActionButton(
                backgroundColor: Colors.grey.shade900,
                foregroundColor: Colors.white,
                child: const Icon(Icons.print),
                onPressed: () async {
                  topSnackBar(context, '🖨️ Printing...');
                  await printDeliveryNote(note);
                },
              )
              : null,
    );
  }
}
