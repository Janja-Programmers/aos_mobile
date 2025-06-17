import 'package:flutter/material.dart';

import '/core/constants/colors.dart';

class LabeledCard extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledCard({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    color: AppColors.cardColor,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    ),
  );
}
