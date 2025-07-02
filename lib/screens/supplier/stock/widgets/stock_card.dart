import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StockCard extends StatelessWidget {
  final String name;
  const StockCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Tap to view details"),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
        onTap: () {
          // 🧭 Navigate to detail screen using name

          context.push('/stock-entry/$name');
        },
      ),
    );
  }
}
