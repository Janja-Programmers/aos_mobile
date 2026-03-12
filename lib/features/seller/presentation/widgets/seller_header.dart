import 'package:africaonlinestores/features/seller/domain/aos_seller.dart';
import 'package:flutter/material.dart';

class SellerHeaderCard extends StatelessWidget {
  const SellerHeaderCard({super.key, required this.seller});

  final AOSSellerProfile seller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.person, size: 36),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seller.shopName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: Colors.green, size: 18),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SellerStat(icon: Icons.star, label: "${seller.rating}"),
                _SellerStat(
                  icon: Icons.people,
                  label: "${seller.totalFollowers} Followers",
                ),
                _SellerStat(icon: Icons.calendar_month, label: seller.joined),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "⚡ Typically replies within 1 hour",
              style: TextStyle(fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Chat"),
                onPressed: () {},
              ),

              OutlinedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text("Call"),
                onPressed: () {},
              ),

              ElevatedButton(child: const Text("Follow"), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _SellerStat extends StatelessWidget {
  const _SellerStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
    );
  }
}
