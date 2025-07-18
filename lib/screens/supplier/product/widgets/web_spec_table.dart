import 'package:flutter/material.dart';

import '../controllers/add_item_controller.dart';

class WebsiteSpecificationsTable extends StatelessWidget {
  final AddItemController controller;
  const WebsiteSpecificationsTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Website Specifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Empty state
            if (controller.specControllers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No specifications added yet.'),
              ),

            // Rows
            ...List.generate(controller.specControllers.length, (index) {
              final entry = controller.specControllers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.labelController,
                        decoration: const InputDecoration(labelText: 'Label'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: entry.descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.removeSpecification(index),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Add Row Button at bottom
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: controller.addSpecificationFromNewRow,
                icon: const Icon(Icons.add, size: 18, color: Colors.black),
                label: const Text(
                  'Add Row',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
