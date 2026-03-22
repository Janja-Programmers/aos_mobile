import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class SellerBottomBar extends StatelessWidget {
  const SellerBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.white,
        boxShadow: [const BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Row(
        children: [
          const Icon(Icons.home),

          const SizedBox(width: 12),

          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text("Call"),
              onPressed: () {},
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.message),
              label: const Text("Message"),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
