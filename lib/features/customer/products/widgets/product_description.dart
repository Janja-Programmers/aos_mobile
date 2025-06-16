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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(shortDesc, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Html(
          data: longDesc,
          shrinkWrap: true,
          style: {
            "body": Style(
              fontSize: FontSize(16),
              lineHeight: const LineHeight(1.5),
            ),
            "p": Style(),
          },
        ),
      ],
    );
  }
}
