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
    final cleanHtml = stripOuterDiv(longDesc);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Detail",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (shortDesc.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      shortDesc,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                if (cleanHtml.trim().isNotEmpty)
                  Html(
                    data: cleanHtml,
                    style: {
                      "*": Style(
                        backgroundColor:
                            Colors.transparent, // neutralize background
                      ),
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
                  )
                else
                  const Text("No additional product description available."),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String stripOuterDiv(String html) {
  final regex = RegExp(r'^<div[^>]*>(.*?)<\/div>$', dotAll: true);
  final match = regex.firstMatch(html);
  return match?.group(1)?.trim() ?? html;
}
