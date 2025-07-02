import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/features/d_note/domain/entity/delivery_note.dart';

class DeliveryNoteTile extends StatelessWidget {
  final DeliveryNote note;

  const DeliveryNoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/delivery-note/${note.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.customerName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _statusChip(note.status),
                  const SizedBox(width: 12),
                  Text(
                    'ID: ${note.id}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
            ],
          ),
        ),
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
      // ignore: deprecated_member_use
      backgroundColor: color.withOpacity(0.15),
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
