import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '/shared/models/specifications.dart';

class ProductSpecificationsList extends StatelessWidget {
  final List<Specification> specs;

  const ProductSpecificationsList({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...specs.map(
          (spec) => ListTile(
            title: Text(spec.label),
            subtitle: Html(data: spec.description),
          ),
        ),
      ],
    );
  }
}
