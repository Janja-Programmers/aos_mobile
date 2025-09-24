import 'package:flutter/material.dart';

class DetailInfoCard extends StatelessWidget {
  final Map<String, String> entries;

  const DetailInfoCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey)),
                  Text(e.value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
