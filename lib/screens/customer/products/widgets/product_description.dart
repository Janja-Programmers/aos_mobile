import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDescriptions extends StatelessWidget {
  final String shortDesc;
  final String longDesc;

  const ProductDescriptions({
    super.key,
    required this.shortDesc,
    required this.longDesc,
  });

  @override
  Widget build(BuildContext context) {
    if (shortDesc.isEmpty && longDesc.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Description",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (shortDesc.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              shortDesc,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),

        if (longDesc.isNotEmpty)
          Html(
            data: longDesc,
            shrinkWrap: true,
            style: {
              "body": Style(
                fontSize: FontSize(14),
                lineHeight: const LineHeight(1.5),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "p": Style(margin: Margins.only(bottom: 8)),
            },
          ),
      ],
    );
  }
}
