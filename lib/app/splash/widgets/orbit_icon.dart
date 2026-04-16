import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrbitIcon extends StatelessWidget {
  final int index;

  const OrbitIcon({super.key, required this.index});

  static const icons = [
    Icons.language,
    Icons.shopping_cart,
    Icons.local_shipping,
    Icons.flight,
    Icons.location_on,
    Icons.store,
    Icons.public,
    Icons.inventory,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Icon(icons[index], color: Colors.red, size: 20),
        )
        .animate(delay: (400 + index * 120).ms) // 👈 slightly delayed
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
        )
        .fadeIn();
  }
}
