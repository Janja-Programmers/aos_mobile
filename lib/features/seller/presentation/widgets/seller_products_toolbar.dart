import 'package:flutter/material.dart';

class SellerProductsToolbar extends StatelessWidget {
  const SellerProductsToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Chip(label: Text("All Items")),
          SizedBox(width: 8),
          Chip(label: Text("Sort by")),
          SizedBox(width: 8),
          Chip(label: Text("Categories")),
        ],
      ),
    );
  }
}
