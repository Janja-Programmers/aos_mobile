import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;

  const DetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey.shade300;
    Color statusTextColor = Colors.grey.shade700;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green.shade100;
        statusTextColor = Colors.green.shade800;
        break;
      case 'submitted':
        statusColor = Colors.blue.shade100;
        statusTextColor = Colors.blue.shade800;
        break;
      case 'draft':
        statusColor = Colors.orange.shade100;
        statusTextColor = Colors.orange.shade800;
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 28,
              color: Colors.blueGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
