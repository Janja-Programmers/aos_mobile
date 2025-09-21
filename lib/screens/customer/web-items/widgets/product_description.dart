import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDescription extends StatelessWidget {
  final String shortDesc;
  final String longDesc;

  const ProductDescription({
    super.key,
    required this.shortDesc,
    required this.longDesc,
  });

  @override
  Widget build(BuildContext context) {
    final cleanHtml = stripOuterDiv(longDesc);

    if (shortDesc.isNotEmpty || longDesc.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shortDesc.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                shortDesc,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          if (cleanHtml.trim().isNotEmpty)
            Html(
              data: cleanHtml,
              style: {
                "*": Style(backgroundColor: Colors.transparent),
                "ul": Style(
                  padding: HtmlPaddings.only(left: 16),
                  margin: Margins.symmetric(vertical: 8),
                ),
                "li": Style(
                  margin: Margins.symmetric(vertical: 6),
                  fontSize: FontSize(15),
                  color: Colors.black87,
                ),
                "span": Style(
                  fontSize: FontSize(14),
                  color: Colors.black87,
                  backgroundColor: Colors.transparent,
                ),
                "p": Style(
                  fontSize: FontSize(15),
                  lineHeight: LineHeight.number(1.6),
                  color: Colors.black87,
                ),
                "body": Style(
                  fontSize: FontSize(15),
                  padding: HtmlPaddings.zero,
                  margin: Margins.zero,
                ),
              },
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

String stripOuterDiv(String html) {
  final regex = RegExp(r'^\s*<div[^>]*>([\s\S]*)<\/div>\s*$', multiLine: true);
  final match = regex.firstMatch(html);
  return match?.group(1)?.trim() ?? html;
}
