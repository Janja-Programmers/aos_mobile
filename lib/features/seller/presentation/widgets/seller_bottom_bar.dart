import 'package:flutter/material.dart';

class SellerBottomBar extends StatelessWidget {
  const SellerBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
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
