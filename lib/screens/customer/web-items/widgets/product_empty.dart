import 'package:flutter/material.dart';

class ProductsEmptyWidget extends StatelessWidget {
  final String query;

  const ProductsEmptyWidget({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        query.isEmpty
            ? 'No products available'
            : 'No products found for "$query"',
      ),
    );
  }
}
