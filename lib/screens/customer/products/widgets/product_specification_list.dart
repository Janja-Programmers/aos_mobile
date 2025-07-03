import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '/features/product/domain/product.dart';

class ProductSpecificationsList extends StatelessWidget {
  final List<WebsiteSpecification> specs;

  const ProductSpecificationsList({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Specifications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(5)},
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children:
              specs.map<TableRow>((spec) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        spec.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Html(
                        data: spec.description,
                        shrinkWrap: true,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(14),
                          ),
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }
}
