import 'package:flutter/material.dart';

class LiveRightActions extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onProducts;
  final VoidCallback onFlip;

  const LiveRightActions({
    super.key,
    required this.onLike,
    required this.onProducts,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 120,
      child: Column(
        children: [
          _btn(Icons.favorite_border, onLike),
          const SizedBox(height: 12),
          _btn(Icons.shopping_bag_outlined, onProducts),
          const SizedBox(height: 12),
          _btn(Icons.cameraswitch, onFlip),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.black.withOpacity(.6),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
